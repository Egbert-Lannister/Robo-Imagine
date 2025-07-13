# NCCL configuration
# export NCCL_DEBUG=INFO
# export NCCL_IB_DISABLE=0
# export NCCL_IB_GID_INDEX=3
# export NCCL_NET_GDR_LEVEL=3
# export NCCL_TOPO_FILE=/tmp/topo.txt

# args
name="training_512_v1.0"
config_file=configs/${name}/config.yaml

# save root dir for logs, checkpoints, tensorboard record, etc.
save_root="/nas/101data/wangconglin"

mkdir -p $save_root/$name

## run
CUDA_VISIBLE_DEVICES=2,3,4,5,6,7 nohup python3 -m torch.distributed.launch \
--nproc_per_node=6 --nnodes=1 --master_addr=127.0.0.1 --master_port=12352 --node_rank=0 \
./main/trainer.py \
--base $config_file \
--train \
--name $name \
--logdir $save_root \
--devices 6 \
lightning.trainer.num_nodes=1 > train.log 2>&1 &

## debugging
# CUDA_VISIBLE_DEVICES=0,1,2,3 python3 -m torch.distributed.launch \
# --nproc_per_node=4 --nnodes=1 --master_addr=127.0.0.1 --master_port=12352 --node_rank=0 \
# ./main/trainer.py \
# --base $config_file \
# --train \
# --name $name \
# --logdir $save_root \
# --devices 4 \
# lightning.trainer.num_nodes=1