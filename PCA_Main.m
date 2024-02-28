%%
clc
clear
Set = 'Test';

a_ = 1:16;
J = 30;

for i = 1:length(a_)
    PC2 = zeros(300,300);
    PC3 = zeros(300,300);
    a = a_(i);
    disp(a)
    for v = 'a':'a' %volunteer
        for s=1:30 %sample number
            clc
            disp([num2str(a) ' '  num2str(100*((v-'a')*30 + s)/300) '%']);

            if( (v == 'd' && s == 11) || (v == 'e' && s == 21) || (v == 'f' && s == 21))
                break;
            end

            folder = ['C:\Nadira\Research\Dataset\WiAR-master\Wi ar data\data\' Set];
            baseFileName = ['csi_' v num2str(a) '_' num2str(s) '.dat'];
            fullFileName = fullfile(folder, baseFileName);
            if isfile(fullFileName)
                csi_trace = read_bf_file(fullFileName);
                
                [r, c] = size(csi_trace); %r = number of packets
                y = zeros(r,1);
                for A = 1:3 %antenna number
                    for j = 1:J %subcarrier number
                        for p = 1 : r
                            csi_entry = csi_trace{p};
                            if isempty(csi_entry)
                                break;
                            end
                            csi = get_scaled_csi(csi_entry);
                            x = abs(squeeze(csi(1,:,:)).');
                            y(p) = x(j,A); %Extracting amplitude from 30x3 matrix
                        end
                        y = y(1:p);
                        y = y - sum(y(1:30))/30;
                        if A == 1 && j == 1
                            Y_temp = zeros(p,J);
                            Y = zeros(p,J*3);
                        end
                        Y_temp(1:p,j) = y';
                    end
                    Y(:,(A-1)*J+1:A*J) = Y_temp;
                end
                PC = pca(Y);
                [seg_y1,seg_len] = segmentation_3(PC(:,2));
                [seg_y2,~] = segmentation_3(PC(:,3));

                PC2((30*(v-'a')+s),1:length(seg_y1)) = seg_y1;
                PC3((30*(v-'a')+s),1:length(seg_y2)) = seg_y2;


            end
        end
    end
    con_PC = [PC2(:,1:200) PC3(:,1:200)];
    sgf = sgolayfilt(con_PC,3,11);
    X_v = con_PC;
    save_script(X_v,a,Set);
end
