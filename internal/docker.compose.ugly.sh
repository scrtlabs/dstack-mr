{"bash_script":null,"docker_compose_file":"services:\n  eliza:\n    command:\n    - /bin/sh\n    - -c\n    - |-\n      cd /app\n      echo $${CHARACTER_DATA} | base64 -d > characters/eliza-in-tee.character.json\n      pnpm run start --non-interactive --character=characters/eliza-in-tee.character.json\n    container_name: eliza\n    environment:\n      ACTION_INTERVAL: ${ACTION_INTERVAL}\n      ACTION_TIMELINE_TYPE: ${ACTION_TIMELINE_TYPE}\n      CHARACTER_DATA: ${CHARACTER_DATA}\n      EMBEDDING_OPENAI_MODEL: ${EMBEDDING_OPENAI_MODEL}\n      IMAGE_OPENAI_MODEL: ${IMAGE_OPENAI_MODEL}\n      LARGE_OPENAI_MODEL: ${LARGE_OPENAI_MODEL}\n      MEDIUM_OPENAI_MODEL: ${MEDIUM_OPENAI_MODEL}\n      OPENAI_API_KEY: ${OPENAI_API_KEY}\n      OPENAI_API_URL: ${OPENAI_API_URL}\n      POST_INTERVAL_MAX: ${POST_INTERVAL_MAX}\n      POST_INTERVAL_MIN: ${POST_INTERVAL_MIN}\n      SMALL_OPENAI_MODEL: ${SMALL_OPENAI_MODEL}\n      TWITTER_2FA_SECRET: ${TWITTER_2FA_SECRET}\n      TWITTER_DRY_RUN: ${TWITTER_DRY_RUN}\n      TWITTER_EMAIL: ${TWITTER_EMAIL}\n      TWITTER_PASSWORD: ${TWITTER_PASSWORD}\n      TWITTER_POLL_INTERVAL: ${TWITTER_POLL_INTERVAL}\n      TWITTER_RETRY_LIMIT: ${TWITTER_RETRY_LIMIT}\n      TWITTER_SEARCH_ENABLE: ${TWITTER_SEARCH_ENABLE}\n      TWITTER_SPACES_ENABLE: ${TWITTER_SPACES_ENABLE}\n      TWITTER_TARGET_USERS: ${TWITTER_TARGET_USERS}\n      TWITTER_USERNAME: ${TWITTER_USERNAME}\n    image: phalanetwork/eliza:v0.1.8-alpha.1\n    ports:\n    - 3000:3000\n    restart: always\n    volumes:\n    - /var/run/tappd.sock:/var/run/tappd.sock\n    - tee:/app/db.sqlite\nvolumes:\n  tee:\n","docker_config":{"password":"","registry":null,"username":""},"features":["kms","tproxy-net"],"kms_enabled":true,"manifest_version":1,"name":"eliza-in-tee","pre_launch_script":"\n#!/bin/bash\necho \"----------------------------------------------\"\necho \"Running Phala Cloud Pre-Launch Script v0.0.2\"\necho \"----------------------------------------------\"\nset -e\n\n# Function: Perform Docker cleanup\nperform_cleanup() {\n    echo \"Pruning unused images\"\n    docker image prune -af\n    echo \"Pruning unused volumes\"\n    docker volume prune -f\n}\n\n# Function: Check Docker login status without exposing credentials\ncheck_docker_login() {\n    # Try to verify login status without exposing credentials\n    if docker info 2>/dev/null | grep -q \"Username\"; then\n        return 0\n    else\n        return 1\n    fi\n}\n\n# Function: Check AWS ECR login status\ncheck_ecr_login() {\n    # Check if we can access the registry without exposing credentials\n    if aws ecr get-authorization-token --region $DSTACK_AWS_REGION &>/dev/null; then\n        return 0\n    else\n        return 1\n    fi\n}\n\n# Main logic starts here\necho \"Starting login process...\"\n\n# Check if Docker credentials exist\nif [[ -n \"$DSTACK_DOCKER_USERNAME\" && -n \"$DSTACK_DOCKER_PASSWORD\" ]]; then\n    echo \"Docker credentials found\"\n    \n    # Check if already logged in\n    if check_docker_login; then\n        echo \"Already logged in to Docker registry\"\n    else\n        echo \"Logging in to Docker registry...\"\n        # Login without exposing password in process list\n        if [[ -n \"$DSTACK_DOCKER_REGISTRY\" ]]; then\n            echo \"$DSTACK_DOCKER_PASSWORD\" | docker login -u \"$DSTACK_DOCKER_USERNAME\" --password-stdin \"$DSTACK_DOCKER_REGISTRY\"\n        else\n            echo \"$DSTACK_DOCKER_PASSWORD\" | docker login -u \"$DSTACK_DOCKER_USERNAME\" --password-stdin\n        fi\n        \n        if [ $? -eq 0 ]; then\n            echo \"Docker login successful\"\n        else\n            echo \"Docker login failed\"\n            exit 1\n        fi\n    fi\n# Check if AWS ECR credentials exist\nelif [[ -n \"$DSTACK_AWS_ACCESS_KEY_ID\" && -n \"$DSTACK_AWS_SECRET_ACCESS_KEY\" && -n \"$DSTACK_AWS_REGION\" && -n \"$DSTACK_AWS_ECR_REGISTRY\" ]]; then\n    echo \"AWS ECR credentials found\"\n    \n    # Check if AWS CLI is installed\n    if ! command -v aws &> /dev/null; then\n        echo \"AWS CLI not installed, installing...\"\n        curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"\n        echo \"6ff031a26df7daebbfa3ccddc9af1450 awscliv2.zip\" | md5sum -c\n        if [ $? -ne 0 ]; then\n            echo \"MD5 checksum failed\"\n            exit 1\n        fi\n        unzip awscliv2.zip &> /dev/null\n        ./aws/install\n        \n        # Clean up installation files\n        rm -rf awscliv2.zip aws\n    else\n        echo \"AWS CLI is already installed: $(which aws)\"\n    fi\n    \n    # Configure AWS CLI\n    aws configure set aws_access_key_id \"$DSTACK_AWS_ACCESS_KEY_ID\"\n    aws configure set aws_secret_access_key \"$DSTACK_AWS_SECRET_ACCESS_KEY\"\n    aws configure set default.region $DSTACK_AWS_REGION\n    echo \"Logging in to AWS ECR...\"\n    aws ecr get-login-password --region $DSTACK_AWS_REGION | docker login --username AWS --password-stdin \"$DSTACK_AWS_ECR_REGISTRY\"\n    if [ $? -eq 0 ]; then\n        echo \"AWS ECR login successful\"\n    else\n        echo \"AWS ECR login failed\"\n        exit 1\n    fi\nfi\n\nperform_cleanup\n\necho \"----------------------------------------------\"\necho \"Script execution completed\"\necho \"----------------------------------------------\"\n","public_logs":true,"public_sysinfo":true,"runner":"docker-compose","salt":"83fe0640-b65f-465e-8ce3-8e08422d9730","tproxy_enabled":true,"version":"1.0.0"}