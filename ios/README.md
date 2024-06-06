# DonutPrivacyDialogPlugin

小程序多端donut 隐私弹窗插件

1. 在插件的代码中注册 showPrivacyDialogWithCallback
2. 在project.miniapp.config 配置使用的[多端插件](https://dev.weixin.qq.com/docs/framework/dev/plugin/iosPlugin.html)
3. 在project.miniapp.config 中 mini-ios.privacy.nativePluginId 设置 为 使用的pluginId

即可 使用自定义原生隐私弹窗
