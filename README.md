<h1>ADS-B Decoder - Ruby</h1>

<p>
    Aujourd'hui on je vous présente l'utilisation et le fonctionnement de mon décodeur ADS-B.
</p>

<h2><b>C'est quoi l'ADS-B ?</b></h2>
<p>
    L'ADS-B pour Automatic dependent surveillance-broadcast est un système de surveillance, par sattélite, pour obtenir des informations sur le trafique aerien. Contrairement aux autres signaux celui-ci n'attend aucune intérrogation. Sa position est fixé via un sattélite.
</p>

<img src="explained.jpg">

<h2><b>Comment réceptionner la transmision ADS-B ?</b></h2>
<p>
    Pour se faire je ne vais pas m'attarder sur le côté technique manuelle de la chose, mais il vous faut un outil vous permettant d'intercépter des frequences, tel que le RTL-SDR qui le fait très bien. Il faudra également une antenne réglé sous une fréquence de <b>1090MHz</b>, c'est la fréquence émise par le transpondeur de l'avion. En revanche l'avion n'envoit pas qu'un seul type de transmission. Aujourd'hui les avions utilisent une methode de transmission appelé <b>mode S</b> celui-ci permet une interrogation selective. 
</p>
<img src="modes.png">
<h2><b>Comment détecter que c'est une transmission ADS-B ?</b></h2>
<p>
    En effet dans le mode S il existe plusieurs type, ainsi que leur type de liaison. On peut y voir que dans le tableau ci-dessus. Les modes necessitant une intérrogation et ceux ne nécessitant aucune intérrogation. Si l'on analyse bien le tableau il existe trois format intéressant qui sont 17-18-19.
    Les trois modes sont intéressant ils ne nécessitent aucune interrogation de la part du SSR.
    <br>
    <br>
    Cela veut dire que les format là sont envoyé de manière automatique par l'avion tout comme notre technologie ADS-B. Pour détecter si il s'agit d'une transmission ADS-B il suffit de regarder les 3 premiers bits de notre "ME" qui est un segment de 56 bits envoyé dans la trame ADS-B.
</p>
<img src="adsbmode.png">

<h2><b></b></h2>
