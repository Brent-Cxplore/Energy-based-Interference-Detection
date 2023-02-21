%% �������ż��
clear;
clc;

%% ������ʼ��
% �źŲ���
power = 1; % �����źŹ���
sampleNum = 8192; % ������
sampleFreq = 5e6; % ����Ƶ��

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

for jnrIdx = 1 : jnrLen
    for cycleIdx = 1 : cycleNum
        % ��ӡѭ����Ϣ
        disp(['JNR: ', num2str(jnr(jnrIdx)),...
            '; cycle: ', num2str(cycleIdx), ';']);
        % �����źŲ���
        rng('default');
        fSingle = rand(1,1)*0.8*sampleFreq + 0.1*sampleFreq; % �����ź�Ƶ��
        startSingle = -(sampleNum-1) / (2*sampleFreq); % ��ʼλ��
        stepSingle = 1 / sampleFreq; % ����
        stopSingle = (sampleNum-1) / (2*sampleFreq); % ��ֹλ��
        tSingle = startSingle : stepSingle : stopSingle;
        rng('default');
        phaseSingle = (2*pi).*rand(1, 1); % ������λ������[0, 2*pi]���ȷֲ�
        % �����źŵ�ʱ����ʽ
        signalSingle = exp(1i*(2*pi*fSingle*tSingle + phaseSingle));
        powerSingle = sqrt(power/mean(abs(signalSingle).^2)).*signalSingle;
        noiseSingle = awgn(powerSingle, jnr(jnrIdx), 'measured', 0);
        noiseSingleFft = fft(noiseSingle);

        % FCME����㷨
        interfNumInfo(cycleIdx, jnrIdx) = SUB_FcmeAlg(noiseSingleFft,...
            falseAlarmProb);
    end
    findInterf = find(interfNumInfo(:, jnrIdx) >= detectNumThres);
    detectRate(jnrIdx) = length(findInterf) / cycleNum;
end

%% plot
figure (1);
plot(jnr, detectRate, 'b-*');
xlabel('jnr'); ylabel('Ƶ������'); legend('����');
axis auto; grid on;