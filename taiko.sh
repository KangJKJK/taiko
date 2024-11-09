#!/bin/bash

# 환경 변수 설정
export WORK="/root/taiko_bot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}Taiko 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/caraka15/taiko_bot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. Taiko 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}Taiko 봇을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/caraka15/taiko_bot
    cd "$WORK"

    # Node.js LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install --lts
    nvm use --lts
    npm install

    # config 파일 생성 및 초기화
    {
        echo "{" 
        echo "  \"timezone\": \"Asia/Jakarta\","
        echo "  \"scheduledTime\": \"07:00\","
        echo "  \"confirmation\": {"
        echo "    \"required\": 1,"
        echo "    \"maxRetries\": 3,"
        echo "    \"retryDelay\": 5000"
        echo "  },"
        echo "  \"weth\": {"
        echo "    \"iterations\": 50,"
        echo "    \"interval\": 5,"
        echo "    \"gasPrice\": \"0.4\","
        echo "    \"amount_min\": \"0.000001\","
        echo "    \"amount_max\": \"0.000004\","
        echo "    \"wallets\": {"
        echo "      \"wallet1\": {"
        echo "        \"amount_min\": \"0.000001\","
        echo "        \"amount_max\": \"0.000004\""
        echo "      }"
        echo "    }"
        echo "  },"
        echo "  \"vote\": {"
        echo "    \"iterations\": 70,"
        echo "    \"interval\": 300,"
        echo "    \"maxFee\": \"0.25\","
        echo "    \"maxPriorityFee\": \"0.12\""
        echo "  }"
        echo "}"
    } > "$WORK/config/config.json"

    # 사용자에게 개인키를 입력받습니다.
    read -p "개인키를 입력하세요. 여러 계정일 경우 쉼표로 구분하세요.: " private_keys

    # 개인키를 배열로 변환
    IFS=',' read -r -a keys_array <<< "$private_keys"

    {
        echo "RPC_URL=https://rpc.mainnet.taiko.xyz"
        echo ""
        echo "WETH_CONTRACT_ADDRESS=0xA51894664A773981C6C112C43ce576f315d5b1B6"
        echo "VOTE_CONTRACT_ADDRESS=0x4D1E2145082d0AB0fDa4a973dC4887C7295e21aB"
        echo ""
        echo "TELEGRAM_BOT_TOKEN="
        echo "TELEGRAM_CHAT_ID="
        echo ""
        
        for i in "${!private_keys[@]}"; do
            echo "PRIVATE_KEY_$((i+1))=${private_keys[i]}"
        done
        
    } > "$WORK/.env"

    # 봇 구동 방식 선택
    echo -e "${GREEN}봇 구동 방식을 선택하세요:${NC}"
    echo -e "${YELLOW}1. 즉시 시작${NC}"
    echo -e "${YELLOW}2. 스케줄 실행 (매일 오전 7시)${NC}"
    read -p "선택: " run_choice
    case $run_choice in

      1)
        echo -e "${CYAN}봇을 즉시 시작합니다...${NC}"
        npm run start:weth:now
        ;;
      2)
        echo -e "${CYAN}봇을 스케줄 모드로 시작합니다 (매일 오전 7시 실행).${NC}"
        npm run start:weth
        ;;
      *)
        echo -e "${RED}잘못된 선택입니다. 기본값으로 즉시 시작합니다.${NC}"
        npm run start:weth:now
        ;;
    esac
    ;;
    
  2)
    echo -e "${GREEN}Taiko 봇을 재실행합니다.${NC}"
    
    cd "$WORK"

    # nvm 로드
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    # 봇 구동
    npm install
    # 봇 구동 방식 선택
    echo -e "${GREEN}봇 구동 방식을 선택하세요:${NC}"
    echo -e "${YELLOW}1. 즉시 시작${NC}"
    echo -e "${YELLOW}2. 스케줄 실행 (매일 오전 7시)${NC}"
    read -p "선택: " run_choice
    
    case $run_choice in
      1)
        echo -e "${CYAN}봇을 즉시 시작합니다.${NC}"
        npm install && npm run start:weth:now
        ;;
      2)
        echo -e "${CYAN}봇을 스케줄 모드로 시작합니다 (매일 오전 7시 실행).${NC}"
        npm install && npm run start:weth
        ;;
      *)
        echo -e "${RED}잘못된 선택입니다. 기본값으로 즉시 시작합니다.${NC}"
        npm install && npm run start:weth:now
        ;;
    esac
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac

