# 画伴（Lumiartframe）产品需求文档（PRD）

## 产品概述

**画伴** 是一款面向亲子家庭的 AI 创意应用。核心面向 3-12 岁儿童及其家长，让孩子将自己的手绘画作通过拍照上传，通过语音/文字描述画作并由 AI 自动生成画作描述、动态视频和儿童心理分析报告。

- **目标用户**：3-12 岁儿童（主要操作者）+ 家长（监护与查看报告）
- **核心价值**：将一张静态画作变为有故事、有动画、有教育意义的互动体验
- **解决的问题**：传统绘画缺乏反馈与延伸；家长难以理解孩子画作背后的情感表达

---

## 页面功能详述

### 1. 闪屏页（SplashView）

#### 页面功能
应用启动过渡页，展示品牌标识，提供视觉缓冲，2 秒后自动跳转到登录页。

#### UI布局
- **背景**：奶油色底（`Color.Theme.bg`）+ 均匀分布的圆点纹理（peach 色，20pt 间距）
- **品牌图标**：居中，圆角方块底（peach 色，112×112pt），内嵌白色画笔图标（`paintbrush.fill`，60pt），带 Brutal 风格黑色描边（4pt）+ 右下偏移投影（6pt）
- **品牌名称**：「画伴」，使用站酷快乐体（`ZCOOLKuaiLe-Regular`，64pt），黑色
- **Slogan**：「让故事动起来」，白色文字，红色底标签，Brutal 风格描边 + 投影，带 -2° 微旋转

#### 交互逻辑
- 页面加载后，品牌图标执行弹簧抖动动画（`spring(response:0.4, dampingFraction:0.4)`，持续来回）
- 2 秒后自动调用 `onFinish()` 回调，跳转至登录页

---

### 2. 登录/注册页（LoginView）

#### 页面功能
用户身份验证入口，支持邮箱+密码的登录与注册双模式切换。通过 Supabase Edge Functions 连接 Supabase Auth，使用官方 Supabase Swift SDK 进行认证。

#### UI布局
- **顶部导航栏**：左侧关闭按钮（×，Brutal 圆形按钮，44pt），中间「通行证」徽章（黄色底，圆角胶囊）
- **标题区域**：
  - 主标题「登录画伴」/「加入画伴」（40pt，Typography.title），底部带 peach 色高亮下划线
  - 副标题「输入邮箱和密码开启魔法！」（18pt，灰色）
- **表单区域**：
  - 邮箱输入框（标签浮动样式，「邮箱地址」标签叠在边框上方）
  - 密码输入框（SecureField，同上浮动标签样式）
  - 提交按钮「立即登录」/「注册账号」（红色 Brutal 按钮，带魔法棒图标 `wand.and.stars`）
  - 模式切换链接「没有账号？点击注册」/「已有账号？直接登录」
- **底部**：用户协议与儿童隐私政策声明文字（12pt，灰色）
- **装饰元素**：浮动的黄色星星（右上方）和 peach 色云朵（左侧），带持续浮动动画

#### 交互逻辑
- **表单校验**：邮箱必须包含 `@`，密码最少 6 位，不满足时弹出红色 Toast 提示
- **登录流程**：调用 `AuthService.shared.login()` → 成功后显示绿色 Toast「✨ 登录成功！」→ 1 秒后路由至主页（`router.navigate(to: .main)`）
- **注册流程**：调用 `AuthService.shared.signup()` → 成功后 Toast「🎉 注册成功！请登录」→ 自动切换为登录模式
- **错误处理**：网络异常等错误通过 `error.localizedDescription` 展示在 Toast 中
- **Toast 组件**：顶部弹出，spring 动画入场，2.5 秒后 easeOut 淡出

---

### 3. 主页 Tab 栏（MainTabView）

#### 页面功能
登录后的主框架容器，承载底部 Tab 导航和页面切换。

#### UI布局
- **内容区域**：根据选中 Tab 展示 GalleryView 或 ProfileView
- **底部 Tab 栏**：
  - 黄色背景（`Color.Theme.yellow`），顶部 4pt 黑色分割线
  - 左侧：「画廊」Tab（`photo.stack.fill` 图标 + 文字）
  - 中间：悬浮创作按钮（FAB），红色圆形 64pt，白色加号图标，Brutal 描边 + 投影
  - 右侧：「我的」Tab（`person.crop.circle.fill` 图标 + 文字）
  - 底部预留 34pt Safe Area 空间

#### 交互逻辑
- 点击「画廊」/「我的」Tab 切换对应页面，选中态为黑色，未选为灰色
- 点击中央红色 FAB 按钮，以全屏 Cover 模式打开 CameraView（拍照/创作入口）

---

### 4. 画廊页（GalleryView）

#### 页面功能
展示用户所有已创作的 AI 画作，支持卡片轮播（Carousel）和网格（Grid）两种浏览模式。

#### UI布局
- **顶部导航栏**：
  - 左侧：用户头像（peach 色圆形，内嵌笑脸，Brutal 描边 + 投影）
  - 中间：「我的画廊」徽章（黄色圆角胶囊）
  - 右侧：视图切换按钮（`square.grid.2x2.fill` ↔ `square.fill.on.square.fill`，Brutal 圆形按钮）
- **轮播模式**（默认）：
  - 使用 `TabView` + `PageTabViewStyle`，卡片高度 500pt
  - 每张卡片带 3D 旋转透视效果（Y 轴 15°），缩放效果
  - 底部圆点分页指示器（黑色选中 / 灰色未选，8pt）
- **网格模式**：使用 `GalleryGridView` 展示
- **加载状态**：居中 ProgressView +「正在翻阅画廊...」文字
- **错误状态**：WiFi 断连图标 + 错误描述 + 红色「重试」Brutal 按钮
- **空状态**：相册叠放图标 +「画廊空空如也，快去创作第一幅画作吧！」

#### 画作卡片（ArtworkCard）组件
- **图片区域**（350pt 高）：
  - AsyncImage 加载远程图片，带加载中/失败占位符
  - 如有视频：叠加半透明播放按钮（`play.circle.fill`，44pt）
  - 左上角「AI魔法」徽章（`wand.and.stars` 图标 + 文字，白底圆角胶囊）
- **信息条**（黄色底）：
  - 左侧：作品标题（Typography.headline 28pt）+ 日期（14pt 灰色）
  - 右侧：播放按钮（红色圆形，50pt，有视频时全显，无视频时半透明）
- 整体圆角 24pt，黑色描边 4pt + 偏移投影

#### 交互逻辑
- 页面 `onAppear` 时调用 `GalleryService.shared.fetchGallery()` 从后端拉取数据
- 点击任意卡片 → 以 `fullScreenCover` 模式打开 DetailView（传入对应 Artwork 数据）
- 切换视图模式按钮可在轮播/网格间切换

---

### 5. 相机/拍照页（CameraView）

#### 页面功能
创作流程第一步。用户通过摄像头拍摄画作，或从相册选取已有图片。

#### UI布局
- **背景**：纯黑色
- **顶部**：左上角关闭按钮（×，白色 Brutal 圆形按钮）
- **取景框区域**（3:4 比例）：
  - 未选图时：四角白色 L 形括号（40pt 长，4pt 线宽）+ 居中相机取景图标 + 「把画作放在框内」提示
  - 已选图后：显示选中图片的预览
- **底部控制栏**：
  - 左侧：「相册」按钮（`photo.on.rectangle` 图标 + 文字），使用原生 PhotosPicker
  - 中间：快门按钮（白色描边圆环 80pt + 红色实心圆 64pt）
  - 右侧：选图后出现「确定」按钮（绿色对勾 + 文字）；未选时为透明占位

#### 交互逻辑
- 点击「相册」→ 调用系统 PhotosPicker，选中后自动加载图片数据到 `CreationViewModel.imageData`，并导航至 DescriptionView
- 点击快门按钮 → 真机调用系统相机（UIImagePickerController）；模拟器降级打开相册
- 相机拍摄完成后 → 图片数据写入 ViewModel → 自动导航至 DescriptionView
- 点击「确定」→ 直接导航至 DescriptionView

---

### 6. 语音描述页（DescriptionView）

#### 页面功能
创作流程第二步。用户对画作进行语音描述（录音），或跳过让 AI 自行解读。

#### UI布局
- **顶部导航栏**：返回箭头 + 「讲个故事」徽章（黄色圆角胶囊，带投影）
- **画作预览**：上一步选择的图片预览，圆角 24pt，Brutal 描边 + 投影
- **引导文字**：
  - 未录音时：「这幅画画了什么呀？」+「按住或点击下面的按钮开始录音」
  - 录音中：「听你讲故事...」+「随时可以点击停止」
- **音频波形**：5 条红色胶囊柱，录音时随机高度动画（0.2 秒刷新），未录音时缩为 8pt 扁平态
- **录音按钮**：
  - 红色实心圆 80pt + 白色麦克风图标（未录时）
  - 白色圆 + 红色方形停止图标（录音中）
  - Brutal 描边 + 投影
- **跳过链接**：「或者：跳过，让AI帮我想」（灰色下划线文字）

#### 交互逻辑
- 点击录音按钮 → 切换录音状态，波形动画开始/停止
- 停止录音 → 0.5 秒后自动导航至 GenerationView
- 点击「跳过」→ 生成一张 400×400 的 mock 图片填充至 ViewModel → 调用 `creationVM.submitCreation(image:, audioUrl: nil)` → 导航至 GenerationView

---

### 7. AI 生成等待页（GenerationView）

#### 页面功能
创作流程第三步。展示 AI 处理进度的等待动画，后端通过 Supabase Edge Functions 异步执行图片上传、故事生成（Deepseek API）和视频生成任务提交（Seedance2 轮询模式）。故事生成完成后即导航至 DetailView，视频在后台异步完成。

#### UI布局
- **背景**：奶油色
- **核心动画**：
  - 黄色大圆（150pt），Brutal 描边 + 投影
  - 红色魔法棒图标（`wand.and.stars`，64pt），持续 360° 旋转动画（2 秒一圈）
- **状态文字**：显示 `creationVM.uploadProgressText`，无内容时默认「正在施法...」
- **进度条**：
  - 白色胶囊底框（200×16pt，Brutal 描边）
  - peach 色填充，根据旋转角度分段增长（<90° → 20pt，<180° → 100pt，>180° → 200pt 满）

#### 交互逻辑
- 页面 `onAppear` 时启动旋转动画，同时调用 `creationVM.executeMagicGeneration()`
- 该方法内部按顺序执行：上传图片 → 后端扫描 → 生成视频 → LLM 分析
- 全部成功 → 自动导航至 DetailView 展示最终成果
- 失败 → 留在当前页（待完善错误处理）

---

### 8. 作品详情页（DetailView）

#### 页面功能
展示单幅作品的完整信息，包括高清图片、AI 生成的童话故事、视频播放入口和家长心理分析报告。

#### UI布局
- **悬浮顶部栏**（绝对定位，不随滚动移动）：
  - 左侧：返回箭头（Brutal 圆形白色按钮）
  - 中间：「作品详情」胶囊标签（黑底白字 + 黄色偏移投影）
  - 右侧：分享按钮（`square.and.arrow.up`，半透明，预留功能）
- **可滚动内容区**：
  - **画作展示框**（Hero 区域，300pt 高）：
    - 白色底，圆角 20pt，Brutal 描边 + 投影
    - AsyncImage 加载远程图片或直接展示本地 UIImage 数据
    - 如有视频 → 叠加黑色半透明遮罩 + 红色播放按钮（80pt 圆形，NavigationLink 跳转 VideoPlayerView）
    - 左上角「AI 魔法」徽章
  - **标题 + 日期**：居中展示
  - **童语故事卡片**（白底，Brutal 描边 + 投影）：
    - 标题行：书本图标（`book.fill`，红色）+ 「童语故事」
    - 故事文本区：奶油底色圆角框内，Typography.body 20pt，行间距 6
  - **分隔箭头**：灰色向下箭头（`chevron.down`）
  - **家长报告·性格分析**（黄色底大卡片，Brutal 描边 4pt）：
    - 标题行：黑色圆底脑图标（`brain.head.profile`）+ 「家长报告·性格分析」+ 「🔒 家长可见」标签
    - **创造力分析卡**：红色火焰图标 + 标题下划线 + 文字描述
    - **情绪分析卡**：黄色笑脸图标 + 标题下划线 + 文字描述
    - 其他动态字段（后端可扩展）
    - 「查看完整月度报告」红色 Brutal 按钮（预留功能）

#### 交互逻辑
- 数据来源双路径：从画廊点入传 `fallbackArtwork`；从创作流结束由 `CreationViewModel` 环境注入
- 点击视频播放按钮 → NavigationLink 跳转至 `VideoPlayerView`（全屏 AVKit 播放器）
- 返回按钮 → `dismiss()` 关闭全屏 Cover / 返回导航栈

---

### 9. 个人中心页（ProfileView）

#### 页面功能
展示用户信息、成就统计和设置入口，提供退出登录功能。

#### UI布局
- **头像区域**：
  - peach 色大圆（100pt）+ 白色笑脸图标（60pt），Brutal 描边 + 投影
  - 用户名（从 JWT 邮箱前缀派生，如 `alice`，Typography.title 28pt）
  - 脱敏邮箱（如 `al***@example.com`，14pt 灰色）
- **功能列表**（4 行 ProfileRow 组件）：
  - ⭐ 我的成就（黄色图标底）→ 「已创作 X 幅画作」或「快去创作第一幅吧！」
  - 🔒 家长控制（灰色图标底）→ 「使用时间管理」
  - ⚙️ 通用设置（白色图标底）→ 「音效、通知与缓存」
  - ❓ 帮助与反馈（白色图标底）
  - 每行右侧 `chevron.right` 箭头（预留导航）
- **退出登录按钮**：白色底，Brutal 描边 + 投影

#### 交互逻辑
- 页面 `onAppear` 时从 JWT Token 中解码用户邮箱，从 GalleryService 获取作品数量
- 退出登录 → 清除 `APIClient.shared` 中的 token → 重置根视图窗口 → 导航至登录页

---

## 全局交互说明

### 导航结构
```
SplashView (2s) → LoginView → MainTabView
                                  ├── GalleryView (Tab 1)
                                  │     └── DetailView (fullScreenCover)
                                  │           └── VideoPlayerView (NavigationLink)
                                  ├── CameraView (FAB 触发, fullScreenCover)
                                  │     └── DescriptionView (NavigationStack push)
                                  │           └── GenerationView (push)
                                  │                 └── DetailView (push)
                                  └── ProfileView (Tab 2)
```

### 设计系统（Design System）
- **字体**：站酷快乐体（`ZCOOLKuaiLe-Regular`）用于品牌标题，Typography 系统统一管理标题/正文/按钮字号
- **配色主题**（`Color.Theme`）：
  - `bg`：奶油白背景
  - `red`：主操作色（按钮、录音、播放）
  - `yellow`：Tab 栏 / 徽章 / 高亮底色
  - `peach`：辅助装饰色（头像底、云朵、卡片底）
  - `brutalBorder`：黑色描边
  - `brutalShadow`：黑色偏移投影
- **设计风格**：NeoBrutalism（新野兽派），特征为圆角 + 粗描边（5-6pt）+ 锐利偏移投影（无模糊）+ 鲜明色块 + 高对比度

### 认证与安全
- 基于 Supabase Auth 的 JWT Token 认证，使用官方 Supabase Swift SDK
- Token 存储在 `APIClient.shared.accessToken` 内存中
- 请求 Header 携带 `Authorization: Bearer <token>`
- 邮箱脱敏展示（前 2 位明文 + 后续星号）
- 儿童隐私政策声明（登录页底部）

### 数据架构
- **开发阶段**：Mock 数据提取至独立 JSON 文件（artworks.json, users.json, stories.json, analysis.json），不硬编码
- **生产阶段**：通过 Supabase Edge Functions 与数据库交互
- **视频生成**：采用轮询 + Supabase Realtime 混合模式处理 Seedance2 API（Seedance2 不支持回调）
  1. 客户端调用 `generate-video` Edge Function
  2. Function 调用 Seedance2 CVSync2AsyncSubmitTask，获取 task_id
  3. Function 在 DB 创建 artworks 记录（video_status: processing, video_task_id）
  4. Function 立即返回记录 ID（不等待视频完成）
  5. 客户端订阅 Supabase Realtime 监听 artworks 表变化
  6. 客户端同时以 8 秒间隔轮询 `check-video-status` Edge Function 作为降级方案
  7. check-video-status 调用 Seedance2 CVSync2AsyncGetResult 检查状态
  8. 视频完成时：更新 DB 记录（video_status: completed, video_url）
  9. Realtime 推送触发客户端自动刷新
- **UX 改进**：用户不需等待视频生成完成。GenerationView 在故事/分析生成后（约5-10秒）即导航到 DetailView，视频播放按钮显示加载状态直到 video_url 可用。

### 网络请求与错误处理
- 所有网络请求通过 `APIClient.shared` 统一发起（`URLSession` + `async/await`）
- 全局 Toast 通知组件（spring 弹入 + 2.5 秒后淡出，支持成功/错误两态）
- 画廊加载失败 → 错误页 + 重试按钮
- 创作流中后端异常 → 留在 GenerationView（待增强错误路由）

### 业务规则
- 密码最少 6 位
- 单次创作流：拍照 → 描述（可跳过）→ 等待生成 → 查看成果
- 作品数据由后端持久化，前端通过 Gallery API 拉取
- 视频和高清扫描图存储于 Supabase Storage
- LLM 返回故事文本 + 心理分析报告（creativity / mood 等维度）

---

## 产品特色

1. **AI 魔法创作闭环**：拍照 → 语音描述 → AI 自动生成童话故事 + 动画视频 + 心理分析，一站式完成
2. **Soft Brutalism 视觉风格**：鲜明的色块、粗描边和投影，既有现代设计感又不失童趣活力
3. **亲子双视角设计**：孩子看到的是童话故事和动画，家长看到的是专业的性格/情绪分析报告（「🔒 家长可见」标签）
4. **零门槛创作**：录音可跳过由 AI 自主生成，降低儿童使用障碍
5. **多 AI 引擎协同**：Seedance2（视频生成，轮询模式）+ Deepseek（故事与心理分析），通过 Supabase Edge Functions 统一编排调度

---

## 技术架构补充

### 后端架构
- **平台**：Supabase（数据库 + 存储 + Edge Functions + Realtime）
- **认证**：Supabase Auth + 官方 Swift SDK
- **API 设计**：OpenAPI 规范优先，前后端共同遵循
- **Edge Functions**：
  - `upload-image` - 图片上传至 Supabase Storage
  - `generate-story` - 调用 Deepseek API 生成故事和心理分析
  - `generate-video` - 提交 Seedance2 视频生成任务（异步）
  - `check-video-status` - 轮询 Seedance2 任务状态
  - `get-gallery` - 获取用户画廊数据

### 外部 API 集成
**Seedance2（视频生成）**：
- 文档：https://www.volcengine.com/docs/85621/1785204?lang=zh
- Access Key ID: `YOUR_VOLCENGINE_ACCESS_KEY_ID`
- Secret Access Key: `YOUR_VOLCENGINE_SECRET_ACCESS_KEY`

**Deepseek（LLM）**：
- 文档：https://api-docs.deepseek.com/
- API Key: `YOUR_DEEPSEEK_API_KEY`
- 返回 JSON 字段：
  - `story_title` - 前端展示
  - `story_content` - 前端展示
  - `video_prompt` - 传递给 Seedance2
  - `creativity_analysis` - 前端展示
  - `mood_analysis` - 前端展示
  - `additional_insights` - 前端展示

### Seedance2 API 详情
```
API 端点：https://visual.volcengineapi.com
认证：Volcengine HMAC-SHA256 签名（Region: cn-north-1, Service: cv）

提交任务：
POST ?Action=CVSync2AsyncSubmitTask&Version=2022-08-31
Body: {
  req_key: "jimeng_i2v_first_v30",
  image_urls: ["<uploaded_image_url>"],
  prompt: "<video_prompt_from_deepseek>",
  seed: -1,
  frames: 121
}
Response: { code: 10000, data: { task_id: "..." } }

查询结果：
POST ?Action=CVSync2AsyncGetResult&Version=2022-08-31
Body: { req_key: "jimeng_i2v_first_v30", task_id: "..." }
Response (完成): { code: 10000, data: { status: "done", video_url: "..." } }
```

### 开发工具
- **构建系统**：SweetPad（需正确注册 Xcode 项目文件）
- **测试**：XCTest + XCUITest 通过 SweetPad 执行
- **真机测试**：相机和音频功能必须在真实设备上测试

---

## OpenAPI 规范

所有 Edge Functions 使用 Bearer Token 认证（`Authorization: Bearer <supabase_access_token>`）。

### POST /upload-image
- **Content-Type**: `multipart/form-data`
- **Request Body**: `{ image: File (required) }`
- **Response 200**:
```json
{ "id": "string", "image_url": "string" }
```
- **Response 401**:
```json
{ "code": "UNAUTHORIZED", "message": "string" }
```

### POST /generate-story
- **Request Body**:
```json
{ "image_url": "string (required)", "audio_transcript": "string (optional)" }
```
- **Response 200**:
```json
{
  "id": "string",
  "story_title": "string",
  "story_content": "string",
  "video_prompt": "string",
  "creativity_analysis": "string",
  "mood_analysis": "string",
  "additional_insights": "string"
}
```

### POST /generate-video
- **Request Body**:
```json
{ "image_url": "string (required)", "prompt": "string (required)" }
```
- **Response 202**:
```json
{ "task_id": "string", "status": "processing" }
```

### GET /check-video-status?task_id={id}
- **Response 200**:
```json
{ "task_id": "string", "status": "processing|completed|failed", "video_url": "string (optional)" }
```

### GET /get-gallery
- **Response 200**:
```json
{
  "artworks": [{
    "id": "string",
    "title": "string",
    "image_url": "string",
    "video_url": "string (optional)",
    "story_title": "string",
    "story_content": "string",
    "creativity_analysis": "string",
    "mood_analysis": "string",
    "additional_insights": "string",
    "created_at": "string (ISO 8601)"
  }]
}
```

---

## 数据库 Schema

```sql
-- Supabase Auth 管理 auth.users 表

CREATE TABLE artworks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT,
  image_url TEXT NOT NULL,
  video_url TEXT,
  video_task_id TEXT,
  video_status TEXT DEFAULT 'pending',
  story_title TEXT,
  story_content TEXT,
  video_prompt TEXT,
  creativity_analysis TEXT,
  mood_analysis TEXT,
  additional_insights TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE artworks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own artworks" ON artworks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own artworks" ON artworks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own artworks" ON artworks FOR UPDATE USING (auth.uid() = user_id);

ALTER PUBLICATION supabase_realtime ADD TABLE artworks;
```

---

## Mock 数据策略

**方案**：Protocol-oriented 服务层 + Mock 实现

```swift
// 每个 Service 定义 Protocol
protocol GalleryServiceProtocol {
    func fetchGallery() async throws -> [Artwork]
}

// Mock 实现（开发/测试用）
class MockGalleryService: GalleryServiceProtocol { ... }

// Real 实现（生产用）
class SupabaseGalleryService: GalleryServiceProtocol { ... }
```

- Mock 数据定义在独立 JSON 文件中（`MockData/artworks.json` 等）
- ViewModel 仅依赖 Protocol，不依赖具体实现
- SwiftUI Preview 使用 Mock 实现
- 通过 Environment 注入切换 Mock/Real

---

## TDD 开发方法论

每个功能模块遵循 Red-Green-Refactor 循环：
1. 先写失败的测试（XCTest / XCUITest）
2. 写最少代码使测试通过
3. 重构优化
4. 通过 SweetPad 运行测试验证

### 经验教训：SwiftUI NavigationStack Environment 传递

**问题**：在 `NavigationStack` 中，通过 `.navigationDestination(for:)` 推入的视图是 `NavigationStack` 的**兄弟节点**，而非子节点。如果在根视图（如 `CameraView`）上注入 `.environment(vm)`，被推入的 `DescriptionView`、`GenerationView` 等视图将无法获取到该 `@Observable` 对象，导致运行时 Fatal Error。

**修复方案**：所有需要共享的 `@Observable` 对象（如 `CreationViewModel`）必须在 `NavigationStack` **本身**或其**父级**注入 `.environment()`，确保 `.navigationDestination` 中的所有目标视图都能继承。

**测试规则**：
- 单元测试（XCTest）只能覆盖 Service 层和 ViewModel 逻辑，**无法检测** SwiftUI 视图层的 Environment 传递问题
- 涉及多页面导航的功能，**必须**编写 XCUITest 覆盖完整的导航链路
- 每个 `fullScreenCover` / `sheet` / `NavigationStack` 都需要对应的 UI 测试验证 Environment 可用性

### XCUITest 覆盖要求

以下导航流程必须有 XCUITest 覆盖：
1. **创作流程**：MainTabView(FAB) → CameraView → DescriptionView → GenerationView → DetailView
2. **画廊详情**：GalleryView → DetailView（fullScreenCover 路径）
3. **认证流程**：SplashView → LoginView → MainTabView

---

## Supabase CLI 部署

```bash
# 初始化
supabase init
supabase start  # 本地开发

# Edge Function 开发
supabase functions new <function-name>
supabase functions serve  # 本地测试

# 部署
supabase functions deploy <function-name>
supabase db push  # 数据库迁移
```
