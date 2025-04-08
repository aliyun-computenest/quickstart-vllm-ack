#!/bin/bash

# OSS 配置参数
OSS_ENDPOINT="oss-cn-huhehaote-internal.aliyuncs.com"
OSS_REGION="cn-huhehaote"
OSS_ACCESS_KEY_ID="STS.NWZQZgmrxPtg4VDnGDL1gLkAf"
OSS_ACCESS_KEY_SECRET="Ci5tawWrzp9r6oDwhpqHjXGBrtTf2F8BXhkqEhqPSf3J"
OSS_STS_TOKEN="CAISpQR1q6Ft5B2yfSjIr5TvGuDTgK1Z57aMNnD1ikcRQL5Lo67qhDz2IH1Le3NrBO8esfgymGFU6v8dlo1aG8YUaRyYPI5dv7h7tF7wO9KE6+bqwfkoobb9RTDLJ0KlhpWKlD8vymeHKJmXcFnhunJZI9GYHGzQszbHXLSNjZl4FM11OiCzcTtBAvpPOwJms7V0HHDNNPGrQC+I523LFxhQpxZbg2Fy4rjdscqH8Uj/ilzmy+YJqqHsJoSld8B2IKpnV9C80I4QcbHaghNI7x9D+J9/lrAmijDcpYO2BFxJ5xiaPs/J9sFuNAZjepUiH6lNoIIT/J8egOHIkJntwBtgJPxcVz+lJLqt28zZAuikRNVbdL/wICbKycvddMu34QgjZGoGKA5MdsE9b3ZqFR0iQzrGMeqr4lnEfkKoTe2FzaE70ZNy01ivpIfUfATSHOXEjHpDasJmNQQjMVsWwGzscqYBbwELKAM9VufMEd0oNUEO9fm34gTcWncnjFMv5qSnNqOM4/lCN9WuBcIWi7BwPsoW7zEYKH3sUK+rh0suc2hofK1byqGFO+XkteDamr7OPraZVq1b6wkGKG/L0yGKTGtNMSD368Y/bkGD5tzVy6XA4xmIqOW7AR4052inBjUNxzQOi8Pah59j521KuSOE1N6Z6wupHpjO1Dr1s83e98u4lBCwEnK+nwcX1gkp9pMRL2q5VR4d4rSm4lhjwbRpl8A/zEh3gzwagAE+oNxKf23I4Nd2puTV4AWnAMcppIwUsZU63Bk3H/+eNJBYyny8x7dftJtZTMnIvVvsAL2lpWz7T+skJsA1A1ZJwbhUf2FOjbjyPRf/oHwlmlcEgy/hbRIKf6SR6fQkbuRJWT9viDKCyPeHBpcdD9X/aC2c/n8aSthKuWq8L0bw+yAA"

# 需要处理的仓库列表（与原下载脚本保持一致）
REPOS=(
#    "deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
#    "deepseek-ai/DeepSeek-R1-Distill-Qwen-32B"
#    "deepseek-ai/DeepSeek-R1-Distill-Llama-70B"
    "deepseek-ai/DeepSeek-R1"
#    "Qwen/QwQ-32B"
)

function compress_and_upload() {
    local repo=$1
    local log_file=$2
    repo_name=$(basename "$repo")
    tar_file="${repo_name}.tar.gz"

    {
        echo "=== Processing $repo_name ===" | tee -a "$log_file"

        # 检查目录是否存在
        if [ ! -d "$repo_name" ]; then
            echo "[ERROR] Directory $repo_name not found!" | tee -a "$log_file"
            return 1
        fi

        # 压缩文件存在性检查
        if [ -f "$tar_file" ]; then
            echo "[INFO] Existing tarball detected, skip compression" | tee -a "$log_file"
        else
            # 执行压缩
            echo "[INFO] Starting compression..." | tee -a "$log_file"
            if ! tar -czvf /data/"$tar_file" -C "$repo_name" >> "$log_file" 2>&1; then
                echo "[ERROR] Compression failed for $repo_name" | tee -a "$log_file"
                return 2
            fi
            echo "[SUCCESS] Compression completed: $tar_file" | tee -a "$log_file"
        fi

        # 上传到OSS（无论是否新压缩）
        echo "[INFO] Starting OSS upload..." | tee -a "$log_file"
        if aliyun oss cp "$tar_file" "oss://computenest-artifacts-draft-cn-huhehaote/1563457855438522/cn-huhehaote/963ebe3542884043b237/$tar_file" \
            -e "$OSS_ENDPOINT" \
            --region "$OSS_REGION" \
            --mode StsToken \
            --access-key-id "$OSS_ACCESS_KEY_ID" \
            --access-key-secret "$OSS_ACCESS_KEY_SECRET" \
            --sts-token "$OSS_STS_TOKEN" >> "$log_file" 2>&1
        then
            echo "[SUCCESS] Upload completed: $tar_file" | tee -a "$log_file"
        else
            echo "[ERROR] Upload failed: $tar_file" | tee -a "$log_file"
            return 3
        fi
    } &
}

# 启动处理任务
for repo in "${REPOS[@]}"; do
    log_file="upload_$(basename "$repo").log"
    compress_and_upload "$repo" "$log_file"
done

# 等待所有后台任务完成
echo "All compression and upload tasks Started."