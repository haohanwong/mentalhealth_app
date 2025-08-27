# Firebase 配置指南

## 后端配置

### 1. 创建 Firebase 项目
1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目或选择现有项目
3. 启用 Firestore 数据库

### 2. 生成服务账户密钥
1. 在 Firebase 控制台中，转到 "项目设置" > "服务账户"
2. 点击 "生成新的私钥"
3. 下载 JSON 文件并保存到安全位置

### 3. 配置环境变量
在 `backend/.env` 文件中添加：

```bash
# Gemini API 密钥
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase 服务账户密钥路径
FIREBASE_SERVICE_ACCOUNT_PATH=/path/to/your/service-account-key.json

# 或者使用 JSON 字符串（用于部署）
FIREBASE_SERVICE_ACCOUNT_KEY={"type": "service_account", "project_id": "your-project-id", ...}
```

### 4. Firestore 数据库结构

应用会自动在 Firestore 中创建以下集合：

#### `chat_messages`
```javascript
{
  user_id: number,
  message: string,
  response: string,
  timestamp: Timestamp,
  created_at: string,
  sentiment_analysis: {
    score: number,
    polarity: number,
    subjectivity: number,
    classification: string,
    confidence: number,
    keywords_found: array
  }
}
```

#### `emotion_scores`
```javascript
{
  user_id: number,
  score: number,
  content_type: string, // "chat" or "diary"
  content_id: string,
  timestamp: Timestamp,
  created_at: string,
  analysis_data: object
}
```

#### `users`
```javascript
{
  user_id: number,
  username: string,
  email: string,
  updated_at: Timestamp
}
```

#### `diary_entries`
```javascript
{
  user_id: number,
  title: string,
  content: string,
  timestamp: Timestamp,
  created_at: string,
  sentiment_analysis: object
}
```

### 5. 安全规则

在 Firestore 规则中添加以下规则来确保用户只能访问自己的数据：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户只能访问自己的聊天记录
    match /chat_messages/{messageId} {
      allow read, write: if request.auth != null && 
        resource.data.user_id == int(request.auth.token.user_id);
    }
    
    // 用户只能访问自己的情感分数
    match /emotion_scores/{scoreId} {
      allow read, write: if request.auth != null && 
        resource.data.user_id == int(request.auth.token.user_id);
    }
    
    // 用户只能访问自己的日记条目
    match /diary_entries/{entryId} {
      allow read, write: if request.auth != null && 
        resource.data.user_id == int(request.auth.token.user_id);
    }
    
    // 用户只能访问自己的用户数据
    match /users/{userId} {
      allow read, write: if request.auth != null && 
        userId == request.auth.token.user_id;
    }
  }
}
```

## 前端配置（可选）

如果你希望前端直接连接到 Firebase（用于实时更新），可以添加 Firebase SDK：

### 1. 添加 Firebase 到 Flutter 项目

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  firebase_core: ^2.15.1
  cloud_firestore: ^4.9.1
  firebase_auth: ^4.9.0
```

### 2. 配置 Firebase

1. 安装 Firebase CLI
2. 运行 `flutterfire configure`
3. 选择你的 Firebase 项目

### 3. 初始化 Firebase

在 `main.dart` 中：

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

## API 端点

### 聊天相关
- `POST /chat` - 发送消息到 AI 聊天机器人
- `GET /chat/history` - 获取本地数据库的聊天历史
- `GET /chat/history/firebase` - 获取 Firebase 的聊天历史

### 情感分析
- `GET /emotions/trend` - 获取情感趋势分析
- `GET /emotions/analyze?text=` - 分析文本情感

### 心理健康资源
- `GET /resources` - 获取心理健康建议和资源

## 部署注意事项

1. **环境变量**: 确保所有环境变量在生产环境中正确设置
2. **Firebase 安全**: 设置适当的 Firestore 安全规则
3. **API 密钥**: 保护好 Gemini API 密钥和 Firebase 服务账户密钥
4. **CORS**: 在生产环境中设置正确的 CORS 域名

## 故障排除

1. **Firebase 连接失败**: 检查服务账户密钥是否正确
2. **权限错误**: 确保 Firestore 安全规则配置正确
3. **API 限制**: 检查 Gemini API 使用限制和配额
4. **网络错误**: 确保防火墙允许访问 Firebase 和 Gemini API