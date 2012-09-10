files = dir('user_instance/*.dat');
for i = 1:numel(files)
    filename = strcat('user_instance/', files(i).name)
    data = load(filename);
    y = data(:,43);
    y(y==-1)=0;
    nnz(y)/size(y,1)
end