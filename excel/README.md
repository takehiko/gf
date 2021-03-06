# Excelファイルの見方

以下の画像は、yagura5.xlsxのワークシートです（体育科教育 2016年5月号の50ページの画像とは少し異なります）。

<img alt="5人技「やぐら」のワークシート例" src="https://raw.github.com/wiki/takehiko/gf/images/yagura5.jpg" width="844" height="208">

5人技「やぐら」について、記述しています（[組体操の「やぐら」について - わさっき](http://d.hatena.ne.jp/takehikom/20160329/1459177200)もご覧ください）。1行目はヘッダーです。2行目から6行目まで、1つの行が1人の演技者を表しています。

列ごとに見ていくとき、主軸になるのはE列です。ここには、演技者の名前を書きます。このワークシートでは、「1.1」「1.2」「2.1」「2.2」「3.1」としていますが、実用にあたっては、もちろん、実名のほうがいいでしょう。

ただし「1.1」は、小数ではありません。これは「下から1段目の、左から1番目の人」を表します。俵型人間ピラミッドも、「段.番」で、各演技者の位置を特定できます。三角錐型人間ピラミッドや、人数の多いやぐらでは、「段.列.番」という、3つの数の組み合わせで特定することになります（こういう数の表し方を、情報工学では「ドット付き10進記法」といいます）。

このワークシートをもとにすると、完成形は次のようになります。

* まず2行目、名前が「1.1」の人は、四つんばいの姿勢で左を向きます。
* 3行目で名前が「1.2」の人は、同じく四つんばいの姿勢で、反対側を向きます。
* 次に4行目、名前が「2.1」の人は、中腰の姿勢で左を向き、足は地面につけ、手は「1.1」の人の背中に置きます。
* 5行目で名前が「2.2」の人は、同じく中腰の姿勢で反対側を向き（「2.1」の人とお尻を近づけます。ただしくっつけないほうがいいでしょう）、足は地面に、手は「1.2」の人の背中の上です。
* 最後に6行目の、名前が「3.1」の人が、てっぺんまで登り、「2.1」と「2.2」の人の腰の上にそれぞれの足を置いて、正面を向いてポーズをとれば、完成です。

ところで、このワークシートのA列からD列までは、荷重の計算に使用しません。Excelの操作で、列の挿入や削除をしても、計算結果に影響しないということです。そこで、学級や出席番号などの列を設けておくと便利です。名前の列でソートすれば、複数の学年・学級で構成する場合でも、人物の漏れや重複が見つけやすくなります。

次に、名前より右の列を見ていくことにします。F列には自重（演技者の体重）を記入します。全員が同じとして、試算する場合には、「1」を縦に並べましょう。

G列からI列までは、値を書き込む必要がなく、他のセルから自動で計算されます。G列は、各演技者にかかる荷重で、J列から右の値を使って算出します。H列は荷重を自重で割った値、I列には荷重と自重を足した値となります。

6行目の名前「3.1」の人については、自分に乗る人がいないため、荷重に関するセル（G6とH6）の値は0となっています。他の者は、荷重がだいたい同じくらいかかり、H列の数値から、それは自重の4割前後なのが読み取れます。

J列から右が、荷重をかける関係についての記述です。同じ行の4列分（J列からM列まで）のセルで1つの関係データとなります。

J列には、上位者（着目している行の演技者に、荷重をかける人）の名前を指定します。ここですが、人物名をそのまま書く必要はなく、かわりに「=」から始まる式をセルに書き、他のセルを参照することができます。Excelファイルを開いて、見てもらえるといいのですが、J2のセルには「=E4」と書いてあります。これにより画面上ではE4セルの値、すなわち「2.1」が表示されているわけです。

K列には、上位者が該当行の演技者にどれだけの割合の荷重をかけるかを指定します。K2とK3のセルの値が、ともに0.3なのは、2段目の人が、1段目（最下段）の人の背中に両手を置くためです。

L列は、上位者の荷重+自重（H列の値）を自動で計算します。画像ではL2のセルの値も表示させていますが、指定された行と列が交差する位置にあるセルを取得するINDEX関数と、記号「$」によるセルの絶対参照を組み合わせた、少々複雑な式によって求めています。

M列では、上位者の荷重+自重に割合をかけています。これも自動で計算します。上位者がどれだけの荷重をかけているかを求めています。

ここまでを整理すると、E列とJ列には名前を書きます。F列とK列には、値を設定しておきます。あとはExcelの表計算機能で、G列、H列、I列、L列、M列を自動的に求めてくれるわけです。

ここで紹介した5人技の「やぐら」は、多人数のピラミッドと比べると、シンプルなつくりです。ある演技者に、2人以上の演技者の荷重が直接的にかかることはありません。

もし複数人から荷重がかかるのであれば、JからM列までの4列分のセルをコピーして、N列に貼り付けてください。そして、N列に2番目の上位者の名前、O列にかける割合を書けばいいのです。

また6行目の「3.1」の人は、2段目の2人を通じて、最下段の2人に間接的に支えられていますが、Excelファイル上では、この関係について、荷重の設定をしなくてかまいません（もしすると、2重カウントとなってしまいます）。

このフォーマットでは、演技者ごとに、《かかる負荷》、言い換えると「誰を支えているか」は、簡単に知ることができます。それに対し、《かける負荷》、ですので演技者ごとに「誰が支えているか」を知るのは、人数が多くなると、容易とは言えません。これについてはエクセルの機能で、J列（および右）で名前を検索し、見つかった行のE列を見ることになります。
