%% �������ż��
clear;
clc;

%% ������ʼ��
% �źŲ���
power = 1; % �����źŹ���
sampleNum = 8192; % ������
sampleFreq = 5e6; % ����Ƶ��
multiNum = ceil(5*rand(1, 1)); % �������Ÿ���

% ʵ�����
jnr = -15:5:0; % �����
jnrLen = length(jnr);
cycleNum = 10; % ������

% �㷨����
falseAlarmProb = 1e-5; % �龯����
detectNumThres = 1; % ���ż������ֵ

% �������
detectRate = zeros(1, jnrLen); % ������

%% ���ź������źŲ���
interfNumInfo = zeros(cycleNum, jnrLen); % ���ż����
signalMulti = 0;

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % ��ӡѭ����Ϣ
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % �����źŲ���
        for multiIdx = 1 : multiNum
            rng('default');
            fMulti = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % �����ź�Ƶ��
            startMulti = -(sampleNum-1) / (2*sampleFreq); % ��ʼλ��
            stepMulti = 1 / sampleFreq; % ����
            stopMulti = (sampleNum-1) / (2*sampleFreq); % ��ֹλ��
            tMulti = startMulti : stepMulti : stopMulti;
            rng('default');
            phaseMulti = (2*pi).*rand(1, 1); % ������λ������[0, 2*pi]���ȷֲ�
            % �����źŵ�ʱ����ʽ
            signalMulti = signalMulti + exp(1i*(2*pi*fMulti*tMulti + phaseMulti));
        end
        powerMulti = sqrt(power/mean(abs(signalMulti).^2)).*signalMulti;
        noiseMulti = awgn(powerMulti, jnr(jnrIdx), 'measured', 0);
        noiseMultiFft = fft(noiseMulti);

        % FCME����㷨
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(noiseMultiFft,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'g-*');
xlabel('JNR'); ylabel('Ƶ������'); legend('����');
axis auto; grid on;