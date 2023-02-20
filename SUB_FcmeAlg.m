%% FCME（前向连续均值去除）算法
function [interfNum] = SUB_FcmeAlg(fftData, falseAlarmProb)
dataSorted = sort(abs(fftData));
dataNoise = dataSorted(1 : length(dataSorted)/4);
dataInterf = dataSorted(length(dataSorted)/4+1 : end);
while (~isempty(dataInterf))
    noisePower = sum(dataNoise.^2) / length(dataNoise);
    interfThres = sqrt(-noisePower * log(falseAlarmProb));
    if (dataInterf(1) <= interfThres)
        dataNoise = cat(2, dataNoise, dataInterf(1));
        dataInterf = dataInterf(2 : end);
    else
        break;
    end
end
interfNum = length(dataInterf);
end