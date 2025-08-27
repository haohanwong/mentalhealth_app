# AI 心理健康聊天机器人使用指南

## 功能概述

你的心理健康AI聊天陪伴机器人现在已经完成，包含以下功能：

### 🤖 AI 聊天功能
- **智能对话**: 使用 Gemini AI 提供专业的心理健康支持
- **情感分析**: 实时分析用户情绪状态并提供反馈
- **聊天历史**: 保存和查看所有聊天记录
- **上下文理解**: AI 会记住最近的对话内容

### 📊 情感追踪
- **实时情感分析**: 每条消息都会进行情感分析
- **情感指示器**: 可视化显示情感状态
- **趋势分析**: 查看情感变化趋势

### 💾 数据存储
- **双重存储**: 本地 SQLite + Firebase 云存储
- **实时同步**: 聊天记录自动同步到 Firebase
- **数据安全**: 用户数据加密存储

## 项目结构

```
mental_health_app/
├── backend/                    # Python FastAPI 后端
│   ├── main.py                # 主 API 文件
│   ├── gemini_service.py      # Gemini AI 服务
│   ├── firebase_service.py    # Firebase 集成
│   ├── auth.py                # 用户认证
│   ├── database.py            # 数据库模型
│   ├── sentiment_analysis.py  # 情感分析
│   └── requirements.txt       # Python 依赖
└── frontend/                  # Flutter 前端
    └── lib/
        ├── providers/         # 状态管理
        │   └── chat_provider.dart
        ├── widgets/           # UI 组件
        │   ├── chat_bubble.dart
        │   └── emotion_indicator.dart
        ├── screens/           # 屏幕页面
        │   └── chat/
        │       └── chat_screen.dart
        ├── models/            # 数据模型
        │   └── chat.dart
        └── services/          # API 服务
            └── api_service.dart
```

## 快速开始

### 1. 后端设置

```bash
cd mental_health_app/backend

# 安装依赖
pip install -r requirements.txt

# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，添加你的 API 密钥
nano .env
```

在 `.env` 文件中配置：
```bash
GEMINI_API_KEY=your_gemini_api_key
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/service-account.json
```

启动后端：
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. 前端设置

```bash
cd mental_health_app/frontend

# 获取依赖
flutter pub get

# 生成代码（如果需要）
flutter packages pub run build_runner build

# 运行应用
flutter run
```

## 核心组件说明

### ChatProvider (状态管理)
- 管理聊天消息列表
- 处理消息发送和接收
- 管理加载和错误状态

### ChatBubble (聊天气泡)
- 显示用户和AI的消息
- 包含时间戳和复制功能
- 显示情感分析结果

### EmotionIndicator (情感指示器)
- 可视化情感分析结果
- 显示情感分数和分类
- 支持详细分析视图

### ChatScreen (聊天界面)
- 完整的聊天界面
- 消息输入和发送
- 情感趋势显示
- 聊天历史管理

## API 端点

### 聊天相关
- `POST /chat` - 发送消息给AI
- `GET /chat/history` - 获取聊天历史
- `GET /chat/history/firebase` - 从Firebase获取历史

### 认证相关
- `POST /auth/register` - 用户注册
- `POST /auth/login` - 用户登录
- `GET /auth/me` - 获取用户信息

### 情感分析
- `GET /emotions/trend` - 获取情感趋势
- `GET /emotions/analyze` - 分析文本情感

## 功能特色

### 1. 智能心理健康支持
AI 聊天机器人专门针对心理健康场景进行了优化：
- 提供情感支持和理解
- 推荐循证的应对策略
- 鼓励寻求专业帮助
- 保持非评判性态度

### 2. 实时情感分析
每条用户消息都会进行深度情感分析：
- 情感极性分析 (-1 到 1)
- 主观性分析 (0 到 1)
- 置信度评估
- 关键词提取
- 情感分类 (非常积极、积极、中性、消极、非常消极)

### 3. 数据可视化
- 情感状态的图形化显示
- 情感趋势图表
- 交互式情感详情
- 历史数据分析

### 4. 安全与隐私
- 用户认证和授权
- 数据加密传输
- Firebase 安全规则
- 本地数据备份

## 自定义配置

### 修改AI响应风格
在 `gemini_service.py` 中修改 `system_prompt`：

```python
self.system_prompt = """
你的自定义提示词...
"""
```

### 调整情感分析参数
在 `sentiment_analysis.py` 中修改分析逻辑：

```python
def analyze_sentiment(self, text: str) -> Dict[str, Any]:
    # 自定义情感分析逻辑
```

### 自定义UI主题
在 `main.dart` 中修改主题配置：

```dart
theme: ThemeData(
  primarySwatch: Colors.blue,  // 修改主色调
  // 其他主题配置...
),
```

## 部署建议

### 后端部署
1. 使用 Docker 容器化
2. 配置环境变量
3. 设置 HTTPS
4. 配置 CORS 策略

### 前端部署
1. 构建生产版本: `flutter build apk`
2. 或构建 Web 版本: `flutter build web`
3. 部署到应用商店或Web服务器

### Firebase 配置
1. 设置 Firestore 安全规则
2. 配置 Firebase 认证（可选）
3. 监控使用量和性能

## 故障排除

### 常见问题
1. **Gemini API 错误**: 检查 API 密钥是否正确
2. **Firebase 连接失败**: 验证服务账户密钥
3. **Flutter 构建错误**: 运行 `flutter clean` 后重新构建
4. **网络错误**: 检查后端服务是否正常运行

### 调试技巧
1. 查看后端日志: `uvicorn main:app --log-level debug`
2. 启用 Flutter 调试: `flutter run --debug`
3. 检查网络请求: 使用浏览器开发者工具
4. Firebase 调试: 在 Firebase 控制台查看日志

## 下一步开发

### 可能的功能扩展
1. **语音聊天**: 集成语音识别和合成
2. **群组聊天**: 支持多用户聊天室
3. **个性化推荐**: 基于用户行为的内容推荐
4. **情感日历**: 可视化情感变化日历
5. **专业医生对接**: 连接真实的心理健康专家
6. **多语言支持**: 支持更多语言
7. **离线模式**: 支持离线使用

### 性能优化
1. 实现消息分页加载
2. 添加图片和文件分享
3. 优化数据库查询
4. 实现消息缓存机制

## 支持和反馈

如果你在使用过程中遇到任何问题或有改进建议，请：
1. 检查文档和故障排除部分
2. 查看项目的 GitHub Issues
3. 联系开发团队

祝你使用愉快！这个AI聊天陪伴机器人将为用户提供专业的心理健康支持。