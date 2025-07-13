# RoboImagine: An Image-Text Conditioned, Generalized Robotic Video Generation Model Across Embodiments and Tasks

[![Project Page](https://img.shields.io/badge/Project-Page-green)](https://github.com/Egbert-Lannister/Robo-Imagine)
[![Paper](https://img.shields.io/badge/Paper-arXiv-red)](https://arxiv.org/abs/your-paper-id)
[![Demo](https://img.shields.io/badge/Demo-Videos-blue)](https://egbert-lannister.github.io/Robo-Imagine/)
[![ModelScope](https://img.shields.io/badge/ModelScope-Link-orange)](https://modelscope.cn/)

## 🚀 Project Overview

**RoboImagine** is an image-text conditioned diffusion model that generates long-term robotic manipulation videos, supporting multiple robot embodiments (robotic arms, mobile robots, etc.). The model achieves continuous and smooth long video generation through dynamic consistency enhancement techniques and integrates a VLM as a task completion verifier.

### 🔥 Core Innovations

- **Input**: Text instruction + Robot type specification + 3 condition images
- **Output**: Long-term robotic manipulation videos (16 frames, extendable via autoregression)
- **Technology**: U-Net diffusion architecture + Dynamic consistency enhancement + VLM task verifier

### 🎯 Key Features

- **Image-Text Conditioned Generation**: Generate robotic videos conditioned on both visual inputs and text instructions
- **Cross-Embodiment Generalization**: Works across different robot embodiments and manipulation tasks
- **Long-Term Video Generation**: Autoregressive pipeline for generating extended manipulation sequences
- **VLM-Enhanced Quality**: Vision-Language Model as task-completion evaluator
- **Dynamic Consistency**: Advanced augmentation techniques for smooth and continuous motions

### 🏗️ Framework Architecture

![Framework](img/framework.png)

RoboImagine is based on U-Net diffusion model architecture:
- **Encoder**: OpenCLIP text encoder + image encoder
- **Diffusion Model**: 3D U-Net for spatiotemporal processing
- **Decoder**: VAE for video frame reconstruction
- **Conditioning Mechanism**: Hybrid conditioning (text+image) + Image concatenation conditioning

### 📊 Performance Highlights

- **150% Average Success Rate Improvement**: Compared to methods without augmentation
- **Effective Generalization**: Excellent performance on unseen tasks and environments
- **Dual Dataset Validation**: Successfully evaluated on both RT-1 and Bridge datasets

## 🛠️ Environment Setup

### Basic Dependencies

- Python 3.8+
- PyTorch 2.0+
- CUDA 11.0+

### Detailed Installation Steps

```bash
# 1. Create conda environment
conda create -n roboimagine python=3.8
conda activate roboimagine

# 2. Clone repository (originmodel branch)
git clone https://github.com/Egbert-Lannister/Robo-Imagine.git
cd Robo-Imagine

# 3. Install dependencies
pip install -r requirements.txt

# Core dependencies include:
# - torch==2.0.0
# - torchvision
# - transformers==4.25.1
# - open_clip_torch==2.22.0
# - pytorch_lightning==1.9.3
# - opencv_python
# - decord==0.6.0
# - xformers
# - einops==0.3.0
```

## 🚀 Quick Start

### Pre-trained Model Download

Our model is based on the DynamiCrafter pre-trained model with fine-tuning and architectural modifications for robotic video generation.

```bash
# Download DynamiCrafter pre-trained model
# Create checkpoints directory
mkdir -p checkpoints

# Download from Hugging Face
# Visit: https://huggingface.co/Doubiiu/DynamiCrafter_512/tree/main
# Download the model files to checkpoints/ directory

# Or use git lfs (if you have git-lfs installed)
cd checkpoints
git lfs clone https://huggingface.co/Doubiiu/DynamiCrafter_512

# The model should be placed at:
# checkpoints/DynamiCrafter_512/model.ckpt
```

**Model Details:**
- **Base Model**: DynamiCrafter (512×320 resolution)
- **Our Modifications**: Fine-tuned on robotic datasets (RT-1, Bridge, UR5) with architectural enhancements
- **Key Changes**: Dynamic consistency augmentation, VLM integration, cross-embodiment conditioning

### Single Video Inference

```python
# Inference example (Python API)
import sys
sys.path.insert(0, '.')
from scripts.evaluation.inference import *

# Load model
config = OmegaConf.load("configs/inference_512_v1.0.yaml")
model = load_model_checkpoint(model, "path/to/checkpoint.ckpt")

# Prepare input
# Note: Input image size must be 512x320, otherwise output will have black borders
text_instruction = "open the microwave"
condition_images = [img1, img2, img3]  # 3 condition images

# Generate video
video = model.generate(
    text_instruction=text_instruction,
    condition_images=condition_images,
    embodiment="bridge"  # Supported: bridge, rt1, ur5
)
```

### Batch Inference

```bash
# Modify the three key paths in the script:
# 1. ckpt: Point to the downloaded checkpoint file
# 2. prompt_dir: Input images and prompt text directory
# 3. res_dir: Output video save directory

# Run inference (512 resolution)
sh scripts/run.sh 512

# Input data format
# prompt_dir/
# ├── image1.jpg    # Condition images
# ├── image2.jpg
# ├── image3.jpg
# └── prompts.txt   # One text instruction per line
```

### Demo Results

#### RT-1 Dataset Results
- ✅ Pick and place operations
- ✅ Drawer manipulation (open/close)
- ✅ Object movement and positioning
- ✅ Container manipulation

#### Bridge Dataset Results
- ✅ Kitchen appliance operation (fridge, microwave)
- ✅ Tool manipulation (knife, cutting board)
- ✅ Complex multi-step tasks
- ✅ Object arrangement and organization

## 🔧 Model Training

### Dataset Preparation

#### Supported Datasets
- **RT-1**: 599 robotic manipulation videos
- **Bridge**: 513 robotic manipulation videos
- **berkeley_autolab_ur5**: UR5 robotic arm data

#### Data Format
```csv
# RT1-UR5-Bridge_train.csv example
video_path,text_instruction,embodiment
/data/bridge/fridge_open.mp4,"open the fridge","bridge"
/data/rt1/drawer_close.mp4,"close the drawer","rt1"
/data/ur5/pick_apple.mp4,"pick up the apple","ur5"
```

#### Image Preprocessing
- **Important Notice**: Input images must be resized to **512×320** resolution
- Otherwise, the model output videos will have black border issues
- Data loader will automatically perform center cropping and normalization

### Start Training

```bash
# Modify training configuration
# configs/training_512_v1.0/config.yaml key parameters:
# - frame_stride: 2  # Core modification in originmodel branch
# - resolution: [320, 512]  # Height×Width
# - video_length: 16
# - meta_path: /path/to/RT1-UR5-Bridge_train.csv

# Start training
sh configs/training_512_v1.0/run.sh

# Training parameter explanation:
# - batch_size: 2
# - learning_rate: 1e-5
# - max_steps: 100000
# - checkpoint_every: 5000 steps
# - Pre-trained model: Based on DynamiCrafter
```

### Checkpoint Management

```bash
# Training checkpoint save path
checkpoints/
├── dynamicrafter_512_v1/model.ckpt  # Pre-trained model
└── training_512_v1.0/
    ├── epoch_174-step_18000.ckpt    # Training checkpoint
    └── trainstep_checkpoints/
```

## 📁 Code Structure

```
RoboImagine/
├── configs/                    # Configuration files
│   ├── inference_512_v1.0.yaml # Inference configuration
│   └── training_512_v1.0/      # Training configuration
│       ├── config.yaml         # Main configuration file
│       └── run.sh              # Training script
├── lvdm/                       # Core model code
│   ├── models/
│   │   ├── ddpm3d.py          # Diffusion model backbone
│   │   ├── autoencoder.py     # VAE encoder
│   │   └── samplers/          # Samplers
│   ├── modules/
│   │   ├── encoders/
│   │   │   ├── condition.py   # Condition encoder (image+text)
│   │   │   └── resampler.py   # Image resampler
│   │   └── networks/
│   │       └── openaimodel3d.py # 3D U-Net
│   └── data/
│       └── webvid.py          # Dataset loader (supports robot types)
├── scripts/                    # Run scripts
│   ├── run.sh                 # Inference script
│   └── evaluation/
│       ├── inference.py       # Inference entry point
│       └── funcs.py           # Utility functions
├── main/                       # Training related
│   ├── trainer.py             # Training entry point
│   ├── utils_data.py          # Data processing utilities
│   └── callbacks.py           # Training callbacks
├── utils/                      # Utility functions
│   ├── utils.py               # General utilities
│   └── save_video.py          # Video saving utilities
└── prompts/                    # Example prompts
    ├── 512/                   # 512 resolution examples
    └── 1024/                  # 1024 resolution examples
```

### Core File Descriptions

- **`lvdm/models/ddpm3d.py`**: Diffusion model backbone, handles spatiotemporal diffusion process
- **`lvdm/modules/encoders/condition.py`**: Condition encoder, processes text and image conditions
- **`lvdm/data/webvid.py`**: Dataset loader, supports robot type images and video data
- **`scripts/evaluation/inference.py`**: Inference entry point, supports batch video generation
- **`configs/training_512_v1.0/config.yaml`**: Training configuration file, contains all model parameters

<!-- ## 🔄 OriginModel Branch Notes

The current open-source version is based on the **originmodel** branch, with key modifications:
- Condition image sampling stride adjusted from 1 to 2 (`frame_stride=2`)
- Improved temporal consistency of generated videos
- Maintains compatibility with original DynamiCrafter -->

## 🧪 Experimental Evaluation

### Dataset Evaluation
- **RT-1 Dataset**: 599 robotic manipulation videos with different embodiments and tasks
- **Bridge Dataset**: 513 robotic manipulation videos with various manipulation scenarios

### Performance Metrics
- **Success Rate**: 150% improvement compared to methods without augmentation
- **Temporal Consistency**: Significantly improved through dynamic consistency enhancement
- **Generalization Capability**: Excellent performance on unseen tasks and environments

## 📝 Citation & License

### Paper Citation

```bibtex
@article{robo_imagine_2024,
  title={Robo-Imagine: An Image-Text Conditioned, Generalized Robotic Video Generation Model Across Embodiments and Tasks},
  author={[Authors will be added]},
  journal={[Journal/Conference will be added]},
  year={2024}
}
```

### License

This project is licensed under the **Apache License 2.0**. See the [LICENSE](LICENSE) file for details.

## 📞 Contact

- **Email**: egbertlannister@gmail.com
- **Issues**: Please use GitHub Issues for technical questions
- **Project Page**: https://egbert-lannister.github.io/Robo-Imagine/

## 🙏 Acknowledgments

- Thanks to the DynamiCrafter project for providing the base model framework
- Thanks to RT-1 and Bridge dataset contributors
- Thanks to open-source projects like OpenCLIP and PyTorch Lightning

---

**⭐ If this project is helpful to you, please give us a star!**

**📧 Subscribe to notifications or watch this repository for the latest updates and feature releases.** 