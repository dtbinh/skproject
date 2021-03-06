%% Sigma-Delta A/D Conversion
% This example shows how to model analog-to-digital conversion using a
% sigma-delta algorithm implementation.

% Copyright 2007-2012 The MathWorks, Inc.

%% Floating-point Example Model
open_system('dspsdadc');
set_param('dspsdadc','StopTime','0.025');
sim('dspsdadc');
%%
bdclose dspsdadc;
%% Fixed-point Example Model
open_system('dspsdadc_fixpt');
set_param('dspsdadc_fixpt','StopTime','0.025');
set_param('dspsdadc_fixpt/Scope1','Open', 'off');
%%
bdclose dspsdadc_fixpt;

%% Exploring the Example
% The Oversampled Sigma-Delta A/D Converter is a noise-shaping quantizer.
% The main purpose of noise-shaping is to reshape the spectrum of
% quantization noise so that most of the noise is filtered out of the
% relevant frequency band, for example, the audio band for speech
% applications. The main objective is to trade bits for samples; that is,
% to increase the sampling rate but reduce the number of bits per sample.
% The resulting increase in quantization noise is compensated by a
% noise-shaping quantizer. This quantizer pushes the added quantization
% noise out of the relevant frequency band and thereby preserves a desired
% level of signal quality. This reduction in the number of bits simplifies
% the structure of A/D and D/A converters.
%
% As seen in this example, the analog input is prefiltered by an antialiasing
% prefilter whose structure is simplified because of oversampling. The
% input signal is oversampled by a factor of 64. The Integrator, 1-Bit
% Quantizer, and Zero-Order Hold blocks comprise a two-level analog to
% digital converter (ADC). The output of the Zero-Order Hold is then
% subtracted from the analog input. The feedback, or approximation, loop
% causes the quantization noise generated by the ADC to be highpass
% filtered, pushing its energy towards the higher frequencies (|64*fs/2|)
% and away from the relevant signal band. The decimation stage reduces the
% sampling rate back to 8 KHz. During this process, it removes the high
% frequency quantization noise that was introduced by the feedback loop and
% removes any undesired frequency components beyond |fs/2| (4 KHz) that
% were not removed by the simple analog prefilter.

%% Decimator Design
% The example versions illustrate two possible decimator design solutions. 
%
% The floating-point version model uses a cascade of three polyphase FIR
% decimators. This approach reduces computation and memory requirements as
% compared to a single decimator by using lower-order filters. Each
% decimator stage reduces the sampling rate by a factor of four. The
% latency introduced by the filters is used to set the appropriate 'Time
% Delay' in the 'Transport Delay' block. The three FIR Decimation filters
% each introduce a latency of 16 samples, due to the group delay of the
% filter (the actual value of 15.5 is rounded up to the nearest integer
% number of samples). Due to the decimation operation the total latency
% introduced by the three filters is as follows: 16 (first filter) + 4*16
% (second filter) + 16*16 (third filter) to give a final total delay of
% 336. The denominator of the 'Time delay' parameter is the base rate of
% the model (512 kHz).
%
% The fixed-point version uses a five-section CIC decimator to reduce the
% sampling rate by the same factor of 64. While not as flexible as a FIR
% decimator, the CIC decimator has the advantage of not requiring any
% multiply operations. It is implemented using only additions,
% subtractions, and delays. Therefore, it is a good choice for a hardware
% implementation where computational resources are limited. The CIC
% Decimator introduces a latency of 158 samples, which is
% the group delay of the filter (157.5) rounded up to the nearest integer.
% This is the value used in 'Time Delay' parameter of the 'Multistage CIC
% Processing Delay' block.

%% References
% Orfanidis, S. J. *Introduction To Signal Processing*, Prentice Hall, 1996.

%% Available Example Versions
% Floating-point version: <matlab:dspsdadc dspsdadc.mdl>
%
% Fixed-point version: <matlab:dspsdadc_fixpt dspsdadc_fixpt.mdl>
