# NSFWJSWrapper

A  NSFW & SFW detecting demo for iOS , based on [nsfwjs](https://github.com/infinitered/nsfwjs) and assembled via WKWebKit


**Feature**

> iOS side indecent content checking，like Porn/Neutral/Sexy/Hentai/Drawing

**Detailed info**
1. ```` branch main ```` for iOS hosted an [GCDWebServer](https://github.com/swisspol/GCDWebServer) serving the model loading

2. ```` branch webresources ````, just replace xxx.json model fetch url 


**Next Step**

* [X] single/multipule UIImage(s) detecting base on [tensorflow](https://baike.baidu.com/item/TensorFlow/18828108)
* [-] ~~load tensflow.js / nsfwjs.js from bundle to speed up the initialzation~~

 >To speed up the initialzation：JavaScript can't load required files from mobile native files system directly, the required files such as ```` quant_nsfw_mobilenet/grop-shard11 quant_nsfw_mobilenet/model.json ```` refed from [github-issues](https://github.com/infinitered/nsfwjs/issues/139), so offering a self hosted web server either from mobile native or remote server should be the way to solve the loading restrict issue.
 
 > JavaScript file loading restricts refs: [Same-origin](https://developer.mozilla.org/zh-CN/docs/Web/Security/Same-origin_policy)

* [ ] gif image support
* [-] UGC contents represented in other way: character sentences, voices detecting feature
* [ ] iOS/Android unified interface integration, under most developing cases should be like this


PS: There may be Not Safe For Work contents in the Demo
