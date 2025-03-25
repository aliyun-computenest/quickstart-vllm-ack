#!/bin/bash

# OSS 配置参数
OSS_ENDPOINT="oss-cn-huhehaote-internal.aliyuncs.com"
OSS_REGION="cn-huhehaote"
OSS_ACCESS_KEY_ID="STS.NWg9nxBM2rDvwY5NLBhQ7BZUM"
OSS_ACCESS_KEY_SECRET="67HftyA86jPghQWEUwjwQ5Fupbzv7fgP8EJVEx1MWH1u"
OSS_STS_TOKEN="CAISpQR1q6Ft5B2yfSjIr5TSctTMr5ITxYaddX+EqkwXZN4brZ/+rzz2IH1Le3NrBO8esfgymGFU6v8dlo1aZcNsbhzpNo5atr19tF78StaEkpbqx/lb07H1Qze4VTOlhZCKxRIByGeHKJmXcFnhunJZI9GYHGzQszbHXLSNjZl4FM11OiCzcTtBAvpPOwJms7V0HHDNNPGrQC+I523LFxhQpxZbg2Fy4rjdscqH8Uj/ilzmy+YJqqHsJoSld8B2IKpnV9C80I4QcbHaghNI7x9D+J9/lrAmijDcpYO2BFxJ5xiaPs/J9sFuNAZjepUiH6lNoIIT/J8egOHIkJntwBtgJPxcVz+lJLqt28zZAuikRNVbdL/wICbKycvddMu34QgjZGoGKA5MdsE9b3ZqFR0iQzrGMeqr4lnEfkKoTe2FzaE70ZNy01ivpIfUfATSHOXEjHpDasJmNQQjMVsWwGzscqYBbwELfwNrX+rLR9t/YEkG9ajhsAfYB3EnjFMv5qSnNqOM4/lCN9WuBcIWi7BwPsoW7zEYKH3sUK+rh0suc2hofK1byqGFO+XkteDamr7OPraZVq1b6wkGKG/L0yGKTGtNMSD368Y/bkGD5tzVy6XA4xmIqOW7AR4052inBjUNxzQOi8Pah5/DL/pYhyOE1N6Z6wupHpjO1Dr1s83e98u4lBCwEnK+nwcX1gkp9pMRL2q5VR4d4rSm4lhjwbRpFVjfT0h3gzwagAGxsd7w8cAKlWEBP6DYKMvcBcBzQplMw+7Cx4cDm/X3M/CS+jAkmtiCFNd9MKV7iVPGK2Qk+n+rGNA4OXfYAKcDxWWfr0bkOfiR4SLPDlugTpD2l9mmFXbJFbWJBJY8mSB22E7HRxjQYgzw0ljC8c4TVv4x+Q+obE9WYfw2rBYtnCAA"

# 需要处理的仓库列表（与原下载脚本保持一致）
REPOS=(
    "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
    "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
    "deepseek-ai/DeepSeek-R1-Distill-Llama-70B"
    "deepseek-ai/DeepSeek-R1"
    "Qwen/QwQ-32B"
)

function compress_and_upload() {
    local repo=$1
    local log_file=$2
    repo_name=$(basename "$repo")

    {
        echo "Processing $repo_name..." | tee -a "$log_file"

        # 检查目录是否存在
        if [ ! -d "$repo_name" ]; then
            echo "Directory $repo_name not found!" | tee -a "$log_file"
            return 1
        fi

        # 压缩目录
        tar_file="${repo_name}.tar.gz"
        echo "Compressing $repo_name..." | tee -a "$log_file"
        tar -czvf "$tar_file" "$repo_name" >> "$log_file" 2>&1

        if [ $? -ne 0 ]; then
            echo "Compression failed for $repo_name" | tee -a "$log_file"
            return 2
        fi

        # 上传到OSS
        echo "Uploading $tar_file to OSS..." | tee -a "$log_file"
        aliyun oss cp "$tar_file" "oss://computenest-artifacts-draft-cn-huhehaote/1563457855438522/cn-huhehaote/963ebe3542884043b237/$tar_file" \
            -e "$OSS_ENDPOINT" \
            --region "$OSS_REGION" \
            --mode StsToken \
            --access-key-id "$OSS_ACCESS_KEY_ID" \
            --access-key-secret "$OSS_ACCESS_KEY_SECRET" \
            --sts-token "$OSS_STS_TOKEN" >> "$log_file" 2>&1

        if [ $? -eq 0 ]; then
            echo "Upload completed: $tar_file" | tee -a "$log_file"
        else
            echo "Upload failed: $tar_file" | tee -a "$log_file"
        fi
    } &
}

# 启动处理任务
for repo in "${REPOS[@]}"; do
    log_file="upload_$(basename "$repo").log"
    compress_and_upload "$repo" "$log_file"
done

# 等待所有后台任务完成
wait
echo "All compression and upload tasks completed."