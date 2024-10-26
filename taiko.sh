#!/bin/bash

# 환경 변수 설정
export WORK="/root/TaikoBot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}Taiko 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/airdropinsiders/TaikoBot${NC}"

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
    git clone https://github.com/airdropinsiders/TaikoBot.git
    cd "$WORK"

    # Node.js LTS 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install --lts
    nvm use --lts
    npm install

    # 사용자에게 트랜잭션 발생 횟수를 입력받습니다.
    read -p "트랜잭션을 몇 번 발생시킬지 입력하세요.: " transaction_count

    # WRAPUNWRAPCOUNT에 입력한 횟수의 절반을 계산합니다.
    wrap_unwrap_count=$((transaction_count / 2))
    
    # config 파일 생성 및 초기화
    {
        echo "export class Config {"
        echo "  static WRAPUNWRAPCOUNT = $wrap_unwrap_count; //1 WRAPUNWRAPCOUNT = 2x TX (랩 / 언랩) 또는 (ETH를 WETH로 스왑하고 다시 스왑)"
        echo "  static TXAMOUNTMIN = 0.0001; //최소 거래 금액"
        echo "  static TXAMOUNTMAX = 0.0002; //최대 거래 금액"
        echo "  static GWEIPRICE = 0.15; //GWEI 가격"
        echo "  static WAITFORBLOCKCONFIRMATION = true; //TRUE일 경우 거래 실행 후 봇이 거래가 채굴될 때까지 대기, FALSE일 경우 거래 실행 후 다음 거래로 진행"
        echo ""
        echo "  //네트워크 제공자 RPC"
        echo "  static RPC = {"
        echo "    CHAINID: 167000,"
        echo "    RPCURL: \"https://rpc.mainnet.taiko.xyz\","
        echo "    EXPLORER: \"https://taikoscan.io/\","
        echo "    SYMBOL: \"ETH\","
        echo "  };"
        echo "  //WETH 계약"
        echo "  static WETHCONTRACTADDRESS = \"0x4200000000000000000000000000000000000006\";"
        echo "}"
    } > "$WORK/config/config.js"


    # 사용자에게 프록시 사용 여부를 물어봅니다.
    read -p "개인키를 입력하세요. 여러 계정일 경우 쉼표로 구분하세요. (y/n): " private_keys

    # 개인키를 배열로 변환
    IFS=',' read -r -a keys_array <<< "$private_keys"

    # accounts.js 파일 생성 및 초기화
    {
        echo "/**"
        echo " * Private key list file"
        echo " * write your private key here like this"
        echo " * export const privateKey = ["
        
        # 개인키를 배열 형식으로 추가
        for i in "${!keys_array[@]}"; do
            echo " *   \"${keys_array[i]}\","
        done

        echo " * ];"
        echo " */"
    } > "$WORK/accounts/accounts.js"

    echo -e "${GREEN}개인키 정보가 .env파일에 저장되었습니다.${NC}"

    # 봇 구동
    npm start
    ;;
    
  2)
    echo -e "${GREEN}Taiko 봇을 재실행합니다.${NC}"
    
    cd "$WORK"

    # nvm 로드
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    # 봇 구동

    npm install
    npm start
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
