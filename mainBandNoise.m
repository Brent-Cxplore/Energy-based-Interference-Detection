%% 部分带噪声干扰检测
clear;
clc;

%% 参数初始化
% 信号参数
power = 1; % 干扰信号功率
sampleNum = 8192; % 采样点
sampleFreq = 5e6; % 采样频率

% 实验参数
jnr = -15:5:0; % 干噪比
jnrLen = length(jnr);
cycleNum = 100; % 检测次数

% 算法参数
falseAlarmProb = 1e-5; % 虚警概率
detectNumThres = 10; % 干扰检出点阈值

% 结果参数
detectRate = zeros(1, jnrLen); % 检测概率

%% 干扰和噪声信号产生
interfNumInfo = zeros(cycleNum, jnrLen); % 干扰检出点

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % 打印循环信息
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % 部分带干扰信号产生
        rng('default');
        allBandNoise = normrnd(0, 1, 1, sampleNum) +...
            1i*normrnd(0, 1, 1, sampleNum);
        rng('default');
        freCenter = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % 干扰信号频率
        bandInterf = 0.005 * sampleFreq; % 部分带带宽
        startBandNoise = -(sampleNum-1) / (2*sampleFreq); % 起始位置
        stepBandNoise = 1 / sampleFreq; % 步长
        stopBandNoise = (sampleNum-1) / (2*sampleFreq); % 终止位置
        tBandNoise = startBandNoise : stepBandNoise : stopBandNoise;
        % 产生带通滤波器
        bandLowPass = sin(2*pi*(bandInterf/2)*tBandNoise) ./ (pi*tBandNoise);
        bandLowPass = bandLowPass / sampleFreq;
        bandFreqShift = exp(1i*(2*pi*freCenter*tBandNoise));
        % BNbandpass=bandLowPass.*bandFreqShift;
        powerBandNoise = filter(bandLowPass,1,[allBandNoise,zeros(1,length(allBandNoise))]);
        powerBandNoise = powerBandNoise((length(allBandNoise)/2)+1:3*length(allBandNoise)/2);
        powerBandNoise = powerBandNoise.*bandFreqShift;
        powerBandNoise = sqrt(power/mean(abs(powerBandNoise).^2)).*powerBandNoise;
        noiseBandNoise = awgn(powerBandNoise, jnr(jnrIdx),'measured',0); 
        noiseBandNoiseFft = fft(noiseBandNoise);

        % FCME检测算法
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(noiseBandNoiseFft,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'y-*');
xlabel('jnr'); ylabel('频域检测率'); legend('部分带');
axis auto; grid on;