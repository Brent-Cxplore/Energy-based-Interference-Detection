%% 多音干扰检测
clear;
clc;

%% 参数初始化
% 信号参数
power = 1; % 干扰信号功率
sampleNum = 8192; % 采样点
sampleFreq = 5e6; % 采样频率
multiNum = ceil(5*rand(1, 1)); % 多音干扰个数

% 实验参数
jnr = -15:5:0; % 干噪比
jnrLen = length(jnr);
cycleNum = 10; % 检测次数

% 算法参数
falseAlarmProb = 1e-5; % 虚警概率
detectNumThres = 1; % 干扰检出点阈值

% 结果参数
detectRate = zeros(1, jnrLen); % 检测概率

%% 干扰和噪声信号产生
interfNumInfo = zeros(cycleNum, jnrLen); % 干扰检出点
signalMulti = 0;

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % 打印循环信息
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % 多音信号产生
        for multiIdx = 1 : multiNum
            rng('default');
            fMulti = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % 干扰信号频率
            startMulti = -(sampleNum-1) / (2*sampleFreq); % 起始位置
            stepMulti = 1 / sampleFreq; % 步长
            stopMulti = (sampleNum-1) / (2*sampleFreq); % 终止位置
            tMulti = startMulti : stepMulti : stopMulti;
            rng('default');
            phaseMulti = (2*pi).*rand(1, 1); % 干扰相位，服从[0, 2*pi]均匀分布
            % 干扰信号的时域表达式
            signalMulti = signalMulti + exp(1i*(2*pi*fMulti*tMulti + phaseMulti));
        end
        powerMulti = sqrt(power/mean(abs(signalMulti).^2)).*signalMulti;
        noiseMulti = awgn(powerMulti, jnr(jnrIdx), 'measured', 0);
        noiseMultiFft = fft(noiseMulti);

        % FCME检测算法
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(noiseMultiFft,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'g-*');
xlabel('JNR'); ylabel('频域检测率'); legend('多音');
axis auto; grid on;