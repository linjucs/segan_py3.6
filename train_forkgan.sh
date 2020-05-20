#!/bin/bash

# Place the CUDA_VISIBLE_DEVICES="xxxx" required before the python call
# e.g. to specify the first two GPUs in your system: CUDA_VISIBLE_DEVICES="0,1" python ...

# SEGAN with no pre-emph and no bias in conv layers (just filters to downconv + deconv)
#CUDA_VISIBLE_DEVICES="2,3" python main.py --init_noise_std 0. --save_path segan_vanilla \
#                                          --init_l1_weight 100. --batch_size 100 --g_nl prelu \
#                                          --save_freq 50 --epoch 50

# SEGAN with pre-emphasis to try to discriminate more high freq (better disc of high freqs)
#CUDA_VISIBLE_DEVICES="1,2,3" python main.py --init_noise_std 0. --save_path segan_preemph \
#                                          --init_l1_weight 100. --batch_size 100 --g_nl prelu \
#                                          --save_freq 50 --preemph 0.95 --epoch 86

# Apply pre-emphasis AND apply biases to all conv layers (best SEGAN atm)
BATCH_SIZE=32
SNR=0
DATA_PATH=/scratch3/jul/new_multi_data/multi_${SNR}
SAVE_PATH=/scratch3/jul/forkgan_check
HINGE_LOSS=true
REDUCTION=true
FULL_CNN=true

DIR=b${BATCH_SIZE}_${SNR}db
if ${HINGE_LOSS} ; then
    DIR=${DIR}_hinge
fi
if ${REDUCTION} ; then
    DIR=${DIR}_reduction
fi
if ${FULL_CNN} ; then
    DIR=${DIR}_cnn
else
    DIR=${DIR}_fc
fi


#python main.py --init_noise_std 0. --save_path ${SAVE_PATH}/${DIR} \
#                                   --init_l1_weight 100. --batch_size ${BATCH_SIZE} --g_nl prelu \
#                                   --synthesis_path ${SAVE_PATH}/dwavegan_samples \
#                                   --e2e_dataset ${DATA_PATH} \
#                                   --save_clean_path ${SAVE_PATH}/test_clean_results_b${BATCH_SIZE}_${SNR}db \
#                                   --save_freq 200 --preemph 0.95 --epoch 86 --bias_deconv True \
#                                   --bias_downconv True --bias_D_conv True \
#                                   --hinge_loss ${HINGE_LOSS} --reduction_loss ${REDUCTION} --cnn_full ${FULL_CNN}

NOISY_WAVNAME="$1"
CLEAN_PATH="."
if [ $# -gt 1 ]; then
    CLEAN_PATH="$2"
fi
mkdir -p $CLEAN_PATH

python main.py --init_noise_std 0. --save_path ${SAVE_PATH}/${DIR} \
               --batch_size 32 --g_nl prelu --weights SEGAN-56072 \
               --preemph 0.95 --bias_deconv True \
               --bias_downconv True --bias_D_conv True \
               --test_dir $NOISY_WAVNAME --save_clean_path $CLEAN_PATH
#perl modify_bit.pl $CLEAN_PATH
#python evaluate.py calculate_pesq --workspace=16_$CLEAN_PATH --speech_dir=../new_dataset/test_clean_${SNR}db --te_snr=0 
#python evaluate.py get_stats


