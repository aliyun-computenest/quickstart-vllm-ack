#!/bin/bash

# 定义克隆和拉取的函数
function clone_and_pull_lfs() {
    local repo=$1
    local log_file=$2
    repo_name=$(basename "$repo" .git)  # 提取仓库目录名（如 DeepSeek-R1-Distill-Qwen-7B）

    {
        echo "Cloning $repo..." >> "$log_file"
        # 使用环境变量抑制 LFS 自动下载，仅获取元数据
        GIT_LFS_SKIP_SMUDGE=1 git clone "https://www.modelscope.cn/$repo.git" >> "$log_file" 2>&1

        if [ $? -eq 0 ]; then
            echo "Starting LFS pull for $repo..." >> "$log_file"
            cd "$repo_name" || {
                echo "Failed to enter directory, skipping..." >> "$log_file"
                exit 1
            }
            # 显式拉取实际文件内容
            git lfs pull >> "../$log_file" 2>&1
            echo "Completed LFS pull for $repo." >> "$log_file"
            cd ..
        else
            echo "Failed to clone $repo. Check $log_file." >> "$log_file"
        fi
    } &
}

# 添加所有需要克隆的仓库
#clone_and_pull_lfs "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B" output7b.log
#clone_and_pull_lfs "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B" output32b.log
#clone_and_pull_lfs "deepseek-ai/DeepSeek-R1-Distill-Llama-70B" output70b.log
clone_and_pull_lfs "deepseek-ai/DeepSeek-R1" output671b.log
#clone_and_pull_lfs "Qwen/QwQ-32B" output-qwq32b.log

echo "All tasks completed."
