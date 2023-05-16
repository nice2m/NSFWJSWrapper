# NSFWJSWrapper

A  NSFW & SFW detecting demo for iOS , based on [nsfwjs](https://github.com/infinitered/nsfwjs) and assembled via WKWebKit


**Feature**

> iOS side indecent content checking，like Porn/Neutral/Sexy/Hentai/Drawing


1. ```` branch main ```` for iOS hosted an [GCDWebServer](https://github.com/swisspol/GCDWebServer) serving the tensorflow model and required js loading, off-line supported, usually takes 5-7 seconds to initialization.

2. ```` branch load_from_remote ````, replace tensorflow_url,nsfwjs_url, model_url(optional) with properly deploied urls in NSFWJSMessager.html,to use the function user should be on-line, required js files tensorflow models should be deployed to a remote server,for team work use case web app, android, ios.


**Next Step**

* [X] single/multipule UIImage(s) detecting base on [tensorflow](https://baike.baidu.com/item/TensorFlow/18828108)
* [-] ~~load tensflow.js / nsfwjs.js from bundle to speed up the initialzation~~ native self hosted http server
* [ ] gif image support
* [-] UGC contents represented in other way: character sentences, voices detecting feature
* [ ] iOS/Android unified interface integration, under most developing cases should be like this


PS: There may be Not Safe For Work contents in the Demo
