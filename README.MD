# NSFWJSWrapper

A  NSFW & SFW detecting demo for iOS , based on [nsfwjs](https://github.com/infinitered/nsfwjs) and assembled via WKWebKit


**Feature**

> iOS side indecent content checking，like Porn/Neutral/Sexy/Hentai/Drawing

1. ``git checkout main`` for iOS hosted an [GCDWebServer](https://github.com/swisspol/GCDWebServer) serving the tensorflow models and required js loading, off-line supported, usually takes 13-27 seconds to initialization.
2. ``git checkout load_from_remote``,within  the file of  `NSFWJSWrapper/nsfwjs/src/NSFWJSMessager.html, `replacing the configs tensorflow_url,nsfwjs_url, model_url(optional) , to use the function user should be on-line, required js files tensorflow models should be deployed to a remote server，usually for team work use case.


**Next Step**

* [X] single/multipule UIImage(s) detecting base on [tensorflow](https://baike.baidu.com/item/TensorFlow/18828108)

* [-] ~~load tensflow.js / nsfwjs.js from bundle to speed up the initialzation~~ native self hosted http server
* [-] UGC contents represented in other way: character sentences, voices detecting feature

* [ ] iOS/Android unified interface integration, under most developing cases should be like this

PS: There may be Not Safe For Work contents in the Demo


**Reference:**

[一个短视频APP视频内容安全审核的思路调研及实现汇总](https://github.com/minitrill/VideoAudit)

[色情图片离线识别，基于TensorFlow实现。识别只需20ms,可断网测试，成功率99%](https://github.com/devzwy/open_nsfw_android)



**替代品：**

open_nsfw_android: [open_nsfw_android](https://github.com/devzwy/open_nsfw_android)

open_nsfw_ios：[open_nsfw_ios](https://github.com/nice2m/open_nsfw_ios "fork 防丢")
