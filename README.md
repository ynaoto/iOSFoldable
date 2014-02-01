Foldable
===========
画像を折り畳んでみたくて作りました。

![Foldable](./snapshot.png)

UIImageView のサブクラスで、設定したイメージを４分割して保持する QuadImageView、さらにサブクラスでタップやスワイプで分割された部分を折り畳めるようにした FoldableQuadImageView 
で構成されています。少し変わった点としては、「折り畳む」アニメーションの際に、折り畳まれる layer が垂直になったところで、layer 間の順番を変えています。これにより、重なったままの紙を折り畳むような動きにしています。それからスワイプのジェスチャ認識と平行して、パンも取るようにしています。常にパンの速度を記録し、スワイプが認識されたときに「勢い」として利用しています。

画像データは「東北ずん子」サイト様 (http://zunko.jp/) のものを利用させて頂いています。この場を借りて御礼申し上げます。

ところで、UISlider に対して、setValue:n animated:YES を送ってもアニメーションしないのは仕様なのでしょうか？ 仕方が無いので、UIView の animateWithDuration:animations: で囲っていますが、どうもスッキリしません・・・。


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ynaoto/iosfoldable/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

