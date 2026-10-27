# Claude 스킬 카탈로그 (21~100번, 80개)

> 출처: 사용자가 준 인쇄물 사진 4장(2026-10-27). 목록 자체는 "2026년 10월 26일 기준"으로 적혀 있다.
> **1~20번은 사진에 없어서 빠져 있다.**
> 사진을 보고 받아 적은 것이라 명령어에 오타가 있을 수 있다. 설치하기 전에 원본 README와 대조할 것.
> 별 개수(★)는 GitHub 스타 수다.

## 쓰기 전에 꼭 알아둘 것 (인쇄물 하단 메모)
- 스킬은 Claude에게 권한을 준다. 설치 화면에 "Review skills before use; they run with full agent permissions"가 나오면 별 수, 업데이트 날짜, 만든 곳을 보고 **회사 공식 스킬부터** 써 본다.
- 계정이나 API 키가 필요한 스킬: 피그마, 캔바, 타빌리(Tavily), 브라우저베이스(Browserbase), 타입펄리(Typefully), 네이버 뉴스 검색. 서비스 계정이나 키가 있어야 실제로 동작한다.
- 플러그인으로 설치되는 스킬은 같은 묶음의 다른 스킬도 함께 깔린다. 필요 없는 건 `/plugin` 메뉴에서 끈다.
- 저장소가 바뀌면 설치 명령어도 바뀔 수 있다. 이름을 눌러 원본 README를 확인한다.
- 스킬 자체는 전부 무료(오픈소스)다. Claude Code 사용료만 든다.
- 이 목록은 Claude Code 기준이다. `npx skills add`로 설치하는 스킬은 `-a` 옵션으로 Codex, Cursor 같은 다른 에이전트에도 깔 수 있다.
- 코딩을 몰라도 된다. 설치 명령어 한 줄만 붙여 넣으면 되고, 쓸 때는 말로 시키면 된다.

## 언제 이 파일을 보나
사용자가 어떤 작업을 요청했을 때, 아래 "이런 일을 해요" 열에서 맞는 스킬을 찾아 이름과 설치 명령을 제안한다. 설치는 사용자가 확인한 뒤에만 한다.

---

## 🎨 디자인 (21~40)

| # | 스킬 | 이런 일을 해요 | 이렇게 말해 보세요 | 만든 곳 · ★ | 설치 명령어 |
|---|---|---|---|---|---|
| 21 | frontend-design | 뻔하지 않은 완성도 높은 웹 화면을 만든다 | "우리 팀 소개 랜딩페이지 세련되게 만들어줘" | Anthropic 공식 · 18.4만 | `/plugin marketplace add anthropics/skills` → `/plugin install example-skills@anthropic-agent-skills` |
| 22 | ui-ux-pro-max | 스타일·색·폰트 조합을 추천해 UI를 다듬는다 | "사내 관리자 화면 UI 개선안 만들어줘" | nextlevelbuilder · 14.1만 | `/plugin marketplace add nextlevelbuilder/ui-ux-pro-max-skill` → `/plugin install ui-ux-pro-max@ui-ux-pro-max-skill` |
| 23 | figma-design-to-code | 피그마 시안을 실제 코드로 옮긴다 | "이 피그마 링크 화면을 코드로 만들어줘" | Figma 공식 · 2,113 | `claude plugin install figma@claude-plugins-official` |
| 24 | figma-generate-design | 설명이나 코드로 피그마 화면을 그린다 | "결제 화면 시안을 피그마에 그려줘" | Figma 공식 · 2,113 | `claude plugin install figma@claude-plugins-official` |
| 25 | figma-generate-diagram | FigJam에 순서도·조직도 같은 도식을 그린다 | "결제 프로세스 순서도 FigJam에 그려줘" | Figma 공식 · 2,113 | `claude plugin install figma@claude-plugins-official` |
| 26 | figma-use-slides | 피그마 슬라이드로 발표자료를 만들고 고친다 | "분기 보고 피그마 슬라이드 10장 만들어줘" | Figma 공식 · 2,113 | `claude plugin install figma@claude-plugins-official` |
| 27 | canva-resize-for-social-media | 캔바 디자인을 SNS 규격별로 한 번에 변환한다 | "이 캔바 포스터 인스타·페북 규격으로 바꿔줘" | Canva 공식 · 137 | `/plugin marketplace add canva-sdks/canva-skills` → `/plugin install canva@canva-skills` |
| 28 | canva-brand-check | 캔바 디자인이 브랜드 규정에 맞는지 점검한다 | "이 캔바 배너 브랜드 가이드 맞는지 봐줘" | Canva 공식 · 137 | 위와 같음 |
| 29 | canva-design-feedback | 캔바 디자인에 구체적인 개선 피드백을 준다 | "이 캔바 카드뉴스 디자인 피드백 줘" | Canva 공식 · 137 | 위와 같음 |
| 30 | canvas-design | 포스터·표지 같은 시각물을 PNG·PDF로 만든다 | "사내 행사 포스터 PNG로 만들어줘" | Anthropic 공식 · 18.4만 | `/plugin marketplace add anthropics/skills` → `/plugin install example-skills@anthropic-agent-skills` |
| 31 | theme-factory | 보고서·슬라이드에 통일된 테마를 입혀 준다 | "이 보고서에 깔끔한 테마 입혀줘" | Anthropic 공식 · 18.4만 | 위와 같음 |
| 32 | frontend-slides | 애니메이션 있는 HTML 발표자료를 만든다 | "이 PPT를 웹 슬라이드로 바꿔줘" | zarazhangrui · 3.1만 | `/plugin marketplace add https://github.com/zarazhangrui/frontend-slides` → `/plugin install frontend-slides@frontend-slides` |
| 33 | design-critique | 사용성·위계·일관성 관점의 디자인 리뷰를 준다 | "이 앱 화면 시안 디자인 리뷰해줘" | Anthropic 공식 · 3.3만 | `claude plugin marketplace add anthropics/knowledge-work-plugins` → `claude plugin install design@knowledge-work-plugins` |
| 34 | ux-copy | 버튼·안내·오류 문구 같은 UX 문구를 다듬는다 | "회원가입 오류 메시지 문구 다듬어줘" | Anthropic 공식 · 3.3만 | 위와 같음 |
| 35 | accessibility-review | 화면이 웹 접근성 기준에 맞는지 점검한다 | "우리 홈페이지 접근성 점검해줘" | Anthropic 공식 · 3.3만 | 위와 같음 |
| 36 | web-design-guidelines | 웹 UI가 인터페이스 가이드라인을 지키는지 본다 | "이 페이지 UI 가이드라인 위반 찾아줘" | Vercel 공식 · 3.3만 | `npx skills add vercel-labs/agent-skills --skill web-design-guidelines` |
| 37 | baoyu-infographic | 글 내용을 인포그래픽 이미지로 정리한다 | "이 보고서 요약을 인포그래픽으로 만들어줘" | JimLiu · 2.7만 | `npx skills add jimliu/baoyu-skills --skill baoyu-infographic` |
| 38 | baoyu-diagram | 구조도·흐름도를 깔끔한 SVG 도식으로 그린다 | "우리 서비스 구조도 SVG로 그려줘" | JimLiu · 2.7만 | `npx skills add jimliu/baoyu-skills --skill baoyu-diagram` |
| 39 | design-md | Stitch 시안에서 디자인 시스템 문서를 뽑는다 | "이 Stitch 프로젝트로 DESIGN.md 만들어줘" | Google 공식 · 8,596 | `npx skills add google-labs-code/stitch-skills --skill design-md` |
| 40 | design-review | 완성된 화면의 여백·위계 문제를 찾아 고친다 | "배포된 사이트 디자인 어색한 곳 고쳐줘" | garrytan · 13.8만 | `git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack && cd ~/.claude/skills/gstack && ./setup` |

## ✍️ 글쓰기·문서 (41~60)

| # | 스킬 | 이런 일을 해요 | 이렇게 말해 보세요 | 만든 곳 · ★ | 설치 명령어 |
|---|---|---|---|---|---|
| 41 | docx | 워드 문서를 만들고 수정하고 변경 추적까지 | "회의 결과로 워드 보고서 만들어줘" | Anthropic 공식 · 18.4만 | `/plugin marketplace add anthropics/skills` → `/plugin install document-skills@anthropic-agent-skills` |
| 42 | pptx | 파워포인트 발표자료를 만들고 편집한다 | "이 내용으로 10장짜리 PPT 만들어줘" | Anthropic 공식 · 18.4만 | 위와 같음 |
| 43 | xlsx | 엑셀 수식·차트·데이터 정리를 해 준다 | "이 매출 엑셀 월별로 피벗해서 차트 넣어줘" | Anthropic 공식 · 18.4만 | 위와 같음 |
| 44 | pdf | PDF 읽기·병합·분할·양식 채우기를 한다 | "이 PDF 3개 합치고 표만 뽑아줘" | Anthropic 공식 · 18.4만 | 위와 같음 |
| 45 | humanizer | AI 티 나는 영어 글을 사람 문장처럼 고친다 | "이 영어 이메일 AI 티 안 나게 고쳐줘" | blader · 6.1만 | `npx skills add blader/humanizer --global --agent claude-code` |
| 46 | humanizer (한국어) | AI가 쓴 한국어의 어색한 패턴을 자연스럽게 | "이 보고서 AI 말투 자연스럽게 바꿔줘" | DaleSeo · 236 | `npx skills add daleseo/korean-skills@humanizer` |
| 47 | korean-spell-check | 한국어 맞춤법·띄어쓰기를 검사해 교정한다 | "이 공지문 맞춤법 검사해줘" | NomaDamas · 8,127 | `npx --yes skills add NomaDamas/k-skill --skill korean-spell-check -g` |
| 48 | kordoc | 한글(HWP·HWPX) 문서를 읽고 양식을 채운다 | "이 HWP 파일 내용 마크다운으로 뽑아줘" | chrisryugj · 2,776 | `/plugin marketplace add chrisryugj/kordoc` → `/plugin install kordoc@kordoc` |
| 49 | hwpx | 한글 HWPX 공문·보고서를 만들고 편집한다 | "이 내용으로 HWPX 공문 만들어줘" | jkf87 · 289 | `npx skills add jkf87/hwpx-skill` |
| 50 | doc-coauthoring | 제안서·기획서를 단계별로 함께 써 나간다 | "신규 사업 제안서 같이 써보자" | Anthropic 공식 · 18.4만 | `/plugin marketplace add anthropics/skills` → `/plugin install example-skills@anthropic-agent-skills` |
| 51 | internal-comms | 주간보고·공지·FAQ 같은 사내 문서를 쓴다 | "이번 주 팀 주간보고 써줘" | Anthropic 공식 · 18.4만 | 위와 같음 |
| 52 | summarize-meeting | 회의 녹취를 결정사항·할 일 중심으로 요약한다 | "이 회의 녹취록 요약하고 할 일 뽑아줘" | phuryn · 2.7만 | `claude plugin marketplace add phuryn/pm-skills` → `claude plugin install pm-execution@pm-skills` |
| 53 | baoyu-translate | 긴 글을 맥락을 살려 자연스럽게 번역한다 | "이 영어 아티클 한국어로 번역해줘" | JimLiu · 2.7만 | `npx skills add jimliu/baoyu-skills --skill baoyu-translate` |
| 54 | translate-book | PDF·워드·EPUB 문서를 통째로 번역한다 | "이 영문 매뉴얼 PDF 한국어로 번역해줘" | deusyu · 2,148 | `npx skills add deusyu/translate-book -a claude-code -g` |
| 55 | review-contract | 계약서에서 불리한 조항과 수정안을 짚어 준다 | "이 용역 계약서 위험 조항 검토해줘" | Anthropic 공식 · 3.3만 | `claude plugin marketplace add anthropics/knowledge-work-plugins` → `claude plugin install legal@knowledge-work-plugins` |
| 56 | status-report | KPI·리스크·할 일이 담긴 현황 보고서를 쓴다 | "이번 달 프로젝트 현황 보고서 써줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install operations@knowledge-work-plugins` |
| 57 | write-spec | 아이디어를 기능 명세서·PRD로 정리한다 | "알림 기능 아이디어로 PRD 써줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install product-management@knowledge-work-plugins` |
| 58 | process-doc | 업무 절차를 순서도·RACI·매뉴얼로 문서화한다 | "구매 요청 절차 업무 매뉴얼로 만들어줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install operations@knowledge-work-plugins` |
| 59 | performance-review | 자기평가·성과평가서 틀을 잡아 작성을 돕는다 | "올해 내 자기평가서 초안 잡아줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install human-resources@knowledge-work-plugins` |
| 60 | triage-nda | 받은 NDA를 승인·검토·위험으로 빠르게 분류한다 | "협력사가 보낸 NDA 빠르게 검토해줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install legal@knowledge-work-plugins` |

## 📈 마케팅·리서치 (61~80)

| # | 스킬 | 이런 일을 해요 | 이렇게 말해 보세요 | 만든 곳 · ★ | 설치 명령어 |
|---|---|---|---|---|---|
| 61 | copywriting | 랜딩페이지·상세페이지 마케팅 문구를 쓴다 | "신제품 상세페이지 카피 써줘" | coreyhaines31 · 5.7만 | `npx skills add coreyhaines31/marketingskills --skill copywriting` |
| 62 | seo-audit | 사이트의 SEO 문제를 진단하고 개선점을 준다 | "우리 회사 홈페이지 SEO 점검해줘" | coreyhaines31 · 5.7만 | `... --skill seo-audit` |
| 63 | customer-research | 고객 인터뷰·리뷰를 분석해 인사이트를 뽑는다 | "고객 리뷰 200개 분석해서 불만 정리해줘" | coreyhaines31 · 5.7만 | `... --skill customer-research` |
| 64 | competitor-profiling | 경쟁사 사이트를 분석해 프로필을 정리한다 | "경쟁사 3곳 URL 분석해서 비교해줘" | coreyhaines31 · 5.7만 | `... --skill competitor-profiling` |
| 65 | social | 링크드인·인스타 등 SNS 콘텐츠를 기획·작성한다 | "이번 주 링크드인 게시물 3개 써줘" | coreyhaines31 · 5.7만 | `... --skill social` |
| 66 | marketing-ideas | 상황에 맞는 마케팅 아이디어를 제안한다 | "신규 고객 늘릴 마케팅 아이디어 10개" | coreyhaines31 · 5.7만 | `... --skill marketing-ideas` |
| 67 | ad-creative | 광고 헤드라인·문구 시안을 여러 개 만든다 | "메타 광고 헤드라인 10개 뽑아줘" | coreyhaines31 · 5.7만 | `... --skill ad-creative` |
| 68 | cold-email | 답장 오는 B2B 콜드메일과 후속 메일을 쓴다 | "잠재 고객사에 보낼 제안 메일 써줘" | coreyhaines31 · 5.7만 | `... --skill cold-email` |
| 69 | ai-seo | ChatGPT 등 AI 검색에 인용되도록 콘텐츠를 다듬는다 | "우리 블로그 글 AI 검색에 잘 걸리게 고쳐줘" | coreyhaines31 · 5.7만 | `... --skill ai-seo` |
| 70 | campaign-plan | 목표·타깃·채널이 담긴 캠페인 기획서를 쓴다 | "연말 프로모션 캠페인 기획서 써줘" | Anthropic 공식 · 3.3만 | `claude plugin marketplace add anthropics/knowledge-work-plugins` → `claude plugin install marketing@knowledge-work-plugins` |
| 71 | competitive-brief | 경쟁사 포지셔닝과 메시지 차이를 비교한다 | "경쟁사 대비 우리 메시지 비교 브리프 써줘" | Anthropic 공식 · 3.3만 | 위와 같음 |
| 72 | keyword-research | 검색 키워드 기회와 지표를 조사해 정리한다 | "우리 제품 관련 SEO 키워드 조사해줘" | every-app · 2.5만 | `npx skills add every-app/open-seo --skill keyword-research` |
| 73 | seo | 사이트 전체 SEO를 종합 감사하고 리포트한다 | "우리 쇼핑몰 SEO 전체 감사해줘" | AgriciDaniel · 2.2만 | `/plugin marketplace add AgriciDaniel/claude-seo` → `/plugin install claude-seo@agricidaniel-claude-seo` |
| 74 | last30days | 최근 30일 레딧·X·유튜브 반응을 모아 정리한다 | "최근 한 달 AI 에이전트 여론 정리해줘" | mvanhorn · 6.6만 | `npx skills add mvanhorn/last30days-skill -g` |
| 75 | tavily-research | 출처가 달린 웹 리서치 보고서를 만든다 | "국내 밀키트 시장 동향 출처 달아 조사해줘" | Tavily 공식 · 491 | `npx skills add https://github.com/tavily-ai/skills --skill tavily-research` |
| 76 | company-research | 회사의 제품·고객층·경쟁사를 깊이 조사한다 | "이 회사 제품이랑 주요 고객 조사해줘" | Browserbase 공식 · 3,742 | `npx skills add browserbase/skills --skill company-research` |
| 77 | user-personas | 리서치 자료로 고객 페르소나 3개를 만든다 | "설문 결과로 고객 페르소나 만들어줘" | phuryn · 2.7만 | `claude plugin marketplace add phuryn/pm-skills` → `claude plugin install pm-market-research@pm-skills` |
| 78 | swot-analysis | 강점·약점·기회·위협 SWOT 분석을 정리한다 | "우리 신사업 SWOT 분석해줘" | phuryn · 2.7만 | 같은 마켓 → `claude plugin install pm-product-strategy@pm-skills` |
| 79 | naver-blog-research | 네이버 블로그 글을 검색해 본문까지 모아 준다 | "네이버 블로그 우리 제품 후기 모아줘" | NomaDamas · 8,127 | `npx --yes skills add NomaDamas/k-skill --skill naver-blog-research -g` |
| 80 | naver-news-search | 네이버 뉴스에서 최신 기사를 찾아 요약한다 | "오늘 우리 업계 네이버 뉴스 정리해줘" | NomaDamas · 8,127 | `npx --yes skills add NomaDamas/k-skill --skill naver-news-search -g` |

`...` = `npx skills add coreyhaines31/marketingskills`

## ⚙️ 업무 자동화 (81~100)

| # | 스킬 | 이런 일을 해요 | 이렇게 말해 보세요 | 만든 곳 · ★ | 설치 명령어 |
|---|---|---|---|---|---|
| 81 | notion-knowledge-capture | 대화 내용을 정리해 노션 문서로 저장한다 | "방금 논의한 내용 노션 위키로 정리해줘" | Notion 공식 · 499 | `/plugin marketplace add makenotion/claude-code-notion-plugin` → `/plugin install notion-workspace-plugin@notion-plugin-marketplace` |
| 82 | notion-meeting-intelligence | 노션 자료를 모아 회의 안건·사전자료를 만든다 | "내일 주간회의 안건 노션에 준비해줘" | Notion 공식 · 499 | 위와 같음 |
| 83 | notion-research-documentation | 노션 여러 페이지를 찾아 종합 보고서로 묶는다 | "노션에서 A프로젝트 자료 모아 정리해줘" | Notion 공식 · 499 | 위와 같음 |
| 84 | notion-spec-to-implementation | 노션 기획서를 할 일 목록으로 쪼개 관리한다 | "이 노션 기획서로 작업 티켓 만들어줘" | Notion 공식 · 499 | 위와 같음 |
| 85 | notion-weekly-project-digest | 노션 진행 상황을 비교해 주간 업데이트를 쓴다 | "노션 보고 이번 주 팀 주간 업데이트 써줘" | Notion 공식 · 220 | `git clone https://github.com/makenotion/notion-cookbook.git && cp -r notion-cookbook/skills/mcp-clients/weekly-project-digest ~/.claude/skills/` |
| 86 | gws-gmail-triage | 안 읽은 지메일을 보낸 사람·제목별로 요약한다 | "안 읽은 메일 중 급한 것만 알려줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-gmail-triage` |
| 87 | gws-calendar-agenda | 모든 구글 캘린더의 다가오는 일정을 보여 준다 | "이번 주 내 일정 정리해줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-calendar-agenda` |
| 88 | gws-sheets | 구글 시트를 읽고 값을 써넣는다 | "이 구글 시트에 오늘 실적 추가해줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-sheets` |
| 89 | gws-drive | 구글 드라이브 파일·폴더·공유를 관리한다 | "드라이브에서 지난달 보고서 찾아줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-drive` |
| 90 | gws-workflow-meeting-prep | 다음 회의의 안건·참석자·관련 문서를 챙긴다 | "다음 회의 준비자료 챙겨줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-workflow-meeting-prep` |
| 91 | gws-workflow-email-to-task | 지메일 메일을 구글 할 일로 바로 등록한다 | "이 메일 내용 할 일로 등록해줘" | Google 공식 · 3.2만 | `npx skills add https://github.com/googleworkspace/cli/tree/main/skills/gws-workflow-email-to-task` |
| 92 | slack-messaging | 슬랙 공지·답장을 읽기 좋게 쓰고 예약한다 | "팀 채널에 올릴 배포 공지 써줘" | Slack 공식 · 156 | `/plugin install slack@claude-plugins-official` |
| 93 | slack-search | 슬랙 메시지·파일·사람을 찾아 맥락을 모은다 | "슬랙에서 예산 관련 논의 찾아줘" | Slack 공식 · 156 | `/plugin install slack@claude-plugins-official` |
| 94 | playwright-cli | 브라우저를 자동 조작해 반복 웹 작업을 한다 | "이 사이트 로그인해서 표 내용 가져와줘" | Microsoft 공식 · 1.5만 | `npm install -g @playwright/cli@latest && playwright-cli install --skills` |
| 95 | browser | 말로 시키면 웹 브라우저 작업을 대신한다 | "이 웹사이트에서 공지사항 목록 모아줘" | Browserbase 공식 · 3,742 | `npx skills add browserbase/skills --skill browser` |
| 96 | skill-creator | 반복 업무를 나만의 스킬로 만들고 개선한다 | "주간보고 작성법을 스킬로 만들어줘" | Anthropic 공식 · 18.4만 | `/plugin marketplace add anthropics/skills` → `/plugin install example-skills@anthropic-agent-skills` |
| 97 | find-skills | 하고 싶은 일에 맞는 스킬을 찾아 설치한다 | "엑셀 자동화에 쓸 스킬 찾아줘" | Vercel 공식 · 3.7만 | `npx skills add vercel-labs/skills --skill find-skills` |
| 98 | analyze | 데이터 질문에 답하고 분석 결과를 정리한다 | "이 매출 CSV로 지역별 추이 분석해줘" | Anthropic 공식 · 3.3만 | `claude plugin marketplace add anthropics/knowledge-work-plugins` → `claude plugin install data@knowledge-work-plugins` |
| 99 | task-management | TASKS.md 파일로 할 일을 정리·추적한다 | "오늘 할 일 정리하고 우선순위 매겨줘" | Anthropic 공식 · 3.3만 | 같은 마켓 → `claude plugin install productivity@knowledge-work-plugins` |
| 100 | typefully | X·링크드인 등 SNS 게시물을 예약 발행한다 | "이 글 내일 9시 링크드인에 예약해줘" | Typefully 공식 · 62 | `npx skills add typefully/agent-skills` |
