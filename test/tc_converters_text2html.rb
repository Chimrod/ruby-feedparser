#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'feedparser/textconverters'

class TextConvertersText2HTMLTest < Test::Unit::TestCase
  def test_detecthtml
    assert('<p>aaa</p>'.html?)
    assert('aaaaa<p>a<p>aa</p>'.html?)
    assert('aaaaa<br>aa'.html?)
    assert(!'aaaaa<bra>aa'.html?)
    assert('aaaaa<br/>aa'.html?)
    assert('aaaaa<br  /    >aa'.html?)
    assert(!'aaa bbb ccc > ddd'.html?)
  end

  def test_text2html
    output = "<p>Les brouillons pour la sp�cification OpenAL 1.1 sont en ligne....</p>
<p>L'annonce et le thread sur la mailing list :
<a href=\"http://opensource.creative.com/pipermail/openal-devel/2005-February(...)\">http://opensource.creative.com/pipermail/openal-devel/2005-February(...)</a></p>
<p>Ou t�l�charger (en pdf ou sxw )
<a href=\"http://openal.org/documentation.html(...)\">http://openal.org/documentation.html(...)</a>
</p>"
    input = <<-EOF
Les brouillons pour la sp�cification OpenAL 1.1 sont en ligne....

L'annonce et le thread sur la mailing list :
http://opensource.creative.com/pipermail/openal-devel/2005-February(...)

Ou t�l�charger (en pdf ou sxw )
http://openal.org/documentation.html(...)
    EOF
    assert_equal(output, input.text2html)
  end

  def test_escapedhtmldetection
    assert('voir &lt;a href=&quote;lien&quote;&gt;'.escaped_html?)
    assert('&lt;img src=&quote;photo&quote;&gt;'.escaped_html?)
    assert('&lt;br&gt;'.escaped_html?)
    assert('&lt;br /&gt;'.escaped_html?)
  end
  def test_escapedhtml
    input = <<-EOF
                             It&#39;s been an exciting few weeks for
&lt;a href=&quot;http://opensolaris.org/os/community/dtrace/&quot;&gt;DTrace&lt;/a&gt;.
The party got started with
&lt;a href=&quot;http://netevil.org/&quot;&gt;Wez Furlong&#39;s&lt;/a&gt; new
&lt;a href=&quot;http://blogs.sun.com/roller/page/bmc?entry=dtrace_and_php_demonstrated&quot;&gt;PHP
DTrace provider&lt;/a&gt; at OSCON.  Then
&lt;a href=&quot;http://www.sitetronics.com/wordpress/&quot;&gt;Devon O&#39;Dell&lt;/a&gt;
announced that he was starting to work in earnest on a
&lt;a href=&quot;http://blogs.sun.com/roller/page/bmc?entry=dtrace_on_freebsd&quot;&gt;DTrace
port to FreeBSD&lt;/a&gt;.  And now,
&lt;a href=&quot;mailto:richlowe@richlowe.net&quot;&gt;Rich Lowe&lt;/a&gt;
has made available a prototype
&lt;a href=&quot;http://richlowe.net/~richlowe/patches/ruby-1.8.2-dtrace.diff&quot;&gt;Ruby
DTrace provider&lt;/a&gt;.
    EOF
    output=<<-EOF
                             It's been an exciting few weeks for\n<a href=\"http://opensolaris.org/os/community/dtrace/\">DTrace</a>.\nThe party got started with\n<a href=\"http://netevil.org/\">Wez Furlong's</a> new\n<a href=\"http://blogs.sun.com/roller/page/bmc?entry=dtrace_and_php_demonstrated\">PHP\nDTrace provider</a> at OSCON.  Then\n<a href=\"http://www.sitetronics.com/wordpress/\">Devon O'Dell</a>\nannounced that he was starting to work in earnest on a\n<a href=\"http://blogs.sun.com/roller/page/bmc?entry=dtrace_on_freebsd\">DTrace\nport to FreeBSD</a>.  And now,\n<a href=\"mailto:richlowe@richlowe.net\">Rich Lowe</a>\nhas made available a prototype\n<a href=\"http://richlowe.net/~richlowe/patches/ruby-1.8.2-dtrace.diff\">Ruby\nDTrace provider</a>.
    EOF
    assert_equal(output, input.text2html)
  end

  def test_unescapehtml
    assert_equal('<', '&lt;'.unescape_html)
  end

  def test_unescape_linuxfr
    input =<<-EOF
Le 17 ao�t 2005, la quasi totalit� de l'actuelle �quipe de d�veloppement du CMS Open Source Mambo a annonc�, dans une lettre ouverte � la communaut�, qu'elle pr�f�re abandonner Mambo suite � la cr�ation de la fondation du m�me nom.&lt;br /&gt;
&lt;br /&gt;
En effet, les d�veloppeurs pensent que l'orientation de Mambo doit �tre dict�e par les demandes de ses utilisateurs et les capacit�s des d�veloppeurs, or il semblerait que la Fondation Mambo soit con�ue pour accorder le contr�le � la soci�t� Miro, une conception qui rend la coop�ration entre la Fondation et la communaut� impossible.&lt;br /&gt;
&lt;br /&gt;
Dans les faits l'�quipe quitte donc la table de la fondation Mambo pour continuer de d�velopper le produit sous GPL, ce qui ressemble donc fort � un fork.


Le deuxi�me pique-nique du libre, organis� par Parinux est ouvert � tous les membres de la communaut� du logiciel libre et � leur famille dans le sens large du terme.&lt;br /&gt;
&lt;br /&gt;
Il est pr�vu pour le samedi 27 ao�t 2005 dans le Parc des Buttes-Chaumont. Rendez-vous de 12h00 � 12h15 � l'entr�e. Apr�s, il faudra trouver le groupe dans le parc. Un plan sur le site de Parinux devrait vous y aider.&lt;br /&gt;
&lt;br /&gt;
Les organisateurs vous demandent d'apporter quelque chose � boire et � manger et si vous le voulez, une couverture, ainsi que vos ballons de foot, de volley, p�tanque, badminton, cerf-volant, etc.

 Comme � son habitude - m�me si �a a pris un peu plus de temps que pr�vu depuis l'annonce de D�cembre 2000 - John Carmack peut aujourd'hui fournir le moteur du jeu &lt;a href=&quot;http://fr.wikipedia.org/wiki/Quake_3&quot;&gt;Quake 3&lt;/a&gt; en GPL. Il est maintenant officiellement disponible sur les ftp de id software comme annonc� par linuX-gamers.&lt;br /&gt;
&lt;br /&gt;
John Carmack avait effectu� la semaine derni�re � QuakeCon 2005 l'annonce de &quot;cette disponibilt� des sources sous une semaine&quot;. Quake III rejoint ainsi les Quake I et II dont le moteur est GPL depuis quelques temps, pour la plus grande joie des amateurs de jeux FPS (First Person Shooter ou &lt;a href=&quot;http://fr.wikipedia.org/wiki/Jeu_de_tir_subjectif&quot;&gt;jeu de tir subjectif en 3D&lt;/a&gt; ou encore Quake-like).&lt;br /&gt;
&lt;br /&gt;
Il y a quelques temps, InternetActu a aussi effectu� une synth�se des raisons d'avoir des jeux libres (dont Nexuiz bas� sur quake1) montrant l'avancement des r�flexions sur le sujet.

    Vous en avez r�v�, vous l'avez r�clam�e... Elle est l� : &lt;br /&gt;
&lt;br /&gt;
LA d�p�che cin�ma sur le tout premier film de Garth Jennings : H2G2 &lt;b&gt;H&lt;/b&gt;itch &lt;b&gt;H&lt;/b&gt;icker's &lt;b&gt;G&lt;/b&gt;uide to the &lt;b&gt;G&lt;/b&gt;alaxy, en fran�ais : H2G2 Le Guide du Voyageur Galactique.&lt;br /&gt;
&lt;br /&gt;
Ce film est - comme tout bon geek qui se respecte le sait - l'adaptation au cin�ma d'une �mission radiophonique cr��e par Douglas Adams. Entre temps, on a eu le droit � cinq romans (constituant une trilogie...), une s�rie TV, un jeu vid�o.&lt;br /&gt;
&lt;br /&gt;
Mais je m'�gare : pour r�sumer le film (mais encore une fois est-ce bien l� peine ?), on suit donc les p�r�grinations intergalactiques du terrien Arthur Dent, apr�s que la terre a �t� ray�e du syst�me solaire. Celui-ci est accompagn� du pr�sident de la galaxie, de Ford Prefect, un ami extraterrestre en provenance d'une petite plan�te pr�s de B�telgeuse, de sa petite amie qui l'a l�ch� quelques heures apr�s l'avoir rencontr�, et de Marvin, un robot d�pressif.&lt;br /&gt;
&lt;br /&gt;
Et tout �a, pour quoi me demanderez-vous ? Mais voyons, trouver la question ultime de la vie, l'univers et tout le reste.

    Les deux grands constructeurs ont mis � jour r�cemment leurs pilotes propri�taires pour GNU/Linux (pour les architectures support�es).&lt;br /&gt;
&lt;br /&gt;
ATI : Sortie le 18/08 de la version 8.16.20 pour X86 et X86-64&lt;br /&gt;
Une grosse mise � jour pour le constructeur canadien :&lt;br /&gt;
Au menu :&lt;br /&gt;
&lt;ul&gt;&lt;br /&gt;
&lt;li&gt;Am�lioration des performances&lt;/li&gt;&lt;li&gt;Support du noyau 2.6.12&lt;/li&gt;&lt;li&gt;Support de GCC 4.0&lt;/li&gt;&lt;li&gt;Correction de certains bugs :&lt;br /&gt;
&lt;ul&gt;&lt;br /&gt;
 &lt;li&gt;R�solution des probl�mes syst�mes avec HDTV et les gros fichiers vid�os.&lt;/li&gt; &lt;li&gt;Le curseur souris n'appara�t plus sur les deux �crans � la fois en multi-t�te.&lt;/li&gt;&lt;li&gt;Le panoramique sur le deuxi�me �cran est maintenant disponible en utilisant les pseudo-couleurs et le mode clone.&lt;/li&gt; &lt;li&gt;Les machines sous Red Hat Enterprise Linux workstation 4 Update 1 et poss�dant 4 Go ou plus de m�moire n'ont plus de probl�me lors du chargement du pilote.&lt;/li&gt; &lt;li&gt;Le support de l'Overlay est disponible sur les machines 64 bits&lt;/li&gt; &lt;li&gt;Des fuites m�moires pour PCIe ont �t� corrig�s.&lt;/li&gt;&lt;br /&gt;
&lt;/ul&gt;&lt;br /&gt;
&lt;/li&gt;&lt;/ul&gt;&lt;br /&gt;
&lt;br /&gt;
NVIDIA : le 09/08 sortait la version 1.0-7676 pour X86 et AMD64&lt;br /&gt;
Ce pilote n'est qu'un correctif du pr�c�dent, il r�gle le probl�me d'horloge pour les GeForce 7800 GTX (donc inutile pour tous ceux qui n'ont pas cette carte).

Le 17 ao�t 2005 est sorti sur vos grands �crans le dernier film de Michael Bay : The Island. (ndla : L'�le).&lt;br /&gt;
&lt;br /&gt;
Disons le tout de suite, vous ne verrez pas vraiment une �le paradisiaque avec plage de sable fin et cocotiers � perte de vue.&lt;br /&gt;
Non, car l'heure est grave : un cataclysme a ravag� la plan�te, qui se trouve maintenant contamin�e.  &lt;br /&gt;
&lt;br /&gt;
Heureusement, certaines personnes survivent et sont ramen�es dans une colonie ferm�e o� vivent nos deux h�ros, incarn�s respectivement par  Ewan McGregor et  Scarlett Johansson.&lt;br /&gt;
Pour illuminer une vie qui serait trop d�sesp�rante, chaque personne participe � une loterie, qui permet � son heureux gagnant de quitter la colonie pour une fabuleuse �le (non contamin�e), o� la vie est plus douce.&lt;br /&gt;
&lt;br /&gt;
Mais bient�t, notre cher Ewan commence � se poser des questions et va d�couvrir la r�alit� terrifiante de The Island ....

    Un long article de The Register revient sur le &lt;i&gt;&quot;Sun's Linux killer&quot;&lt;/i&gt;, � savoir Solaris 10. Le but de l'auteur est davantage de r�aliser un compte-rendu d'utilisation qu'un comparatif, il n'y a notamment (et d�lib�r�ment) pas de benchmark qui pourraient �tayer les dires de l'auteur (Thomas C Green). Il faut donc garder en t�te le c�t� parfaitement subjectif de l'article.&lt;br /&gt;
&lt;br /&gt;
L'auteur souligne pour commencer que si, actuellement et sur la cible vis�e (les PC), GNU/Linux est loin devant, Sun peut se donner les moyens de rattraper son retard ... s'il en a le d�sir.&lt;br /&gt;
&lt;br /&gt;
Pour r�sumer les points forts de Solaris sont :&lt;ul&gt;&lt;li&gt;la maturit� d'Unix, le syst�me est tout particuli�rement stable et il est difficile de le faire s'�crouler.&lt;/li&gt;&lt;li&gt;la rapidit� (subjectif)&lt;/li&gt;&lt;li&gt;la qualit� de &lt;a href=&quot;http://opensolaris.org/os/community/dtrace/&quot;&gt;DTrace&lt;/a&gt;&lt;/li&gt;&lt;li&gt;les zones virtuelles (&lt;i&gt;containers&lt;/i&gt;) qui permettent de g�rer plus finement les ressources allou�es aux programmes&lt;/li&gt;&lt;li&gt;c'est Sun, entendre par l� que �a passera toujours mieux aupr�s d'un DSI de savoir qu'il y a le support de Sun derri�re&lt;/li&gt;&lt;/ul&gt;&lt;br /&gt;
Les points faibles sont :&lt;ul&gt;&lt;li&gt;la phase d'installation n'est pas meilleure qu'une bonne distribution GNU/Linux&lt;/li&gt;&lt;li&gt;le support du mat�riel limit�, l'exemple de la tr�s r�pandue SBLive est parlant.&lt;/li&gt;&lt;li&gt;les choix dans les logiciels propos�s (subjectif on vous a dit)&lt;/li&gt;&lt;li&gt;la jeunesse globale du projet et le c�t� commercial qui rebute encore la communaut�&lt;/li&gt;&lt;/ul&gt;&lt;br /&gt;
Pour conclure, Solaris 10 est plus un bon concurrent en devenir plut�t qu'un &lt;i&gt;&quot;GNU/Linux killer&quot;&lt;/i&gt; cependant il y a de bonnes id�es dans le syst�me qu'il conviendrait d'�tudier de pr�s.

    J'avais d�cid� de ne plus utiliser mon &lt;a href=&quot;http://www.rfi.fr/actufr/articles/062/article_34098.asp&quot;&gt;t�l�phone&lt;/a&gt; et surtout pas mon mobile qui peut fournir &lt;a href=&quot;http://www.transfert.net/a4879&quot;&gt;ma position en continu&lt;/a&gt;. J'avais banni les cartes de fid�lit� des supermarch�s qui permettaient de collecter les informations sur mes go�ts et de les revendre. J'�vitais de m�me les sondages divers commerciaux. Je me disais qu'en payant en liquide (avec un &lt;a href=&quot;http://www.liberation.fr/page.php?Article=315139&quot;&gt;risque de contrefa�on sur les billets&lt;/a&gt; certes) et en n'utilisant pas &lt;a href=&quot;http://www.lexpansion.com/art/2661.80555.0.html&quot;&gt;de pass dans le m�tro&lt;/a&gt;, je pr�serverais un peu de ma libert�. Poussant le raisonnement au bout, j'avais d�cid� d'organiser r�guli�rement des br�ves rencontres avec des inconnus pour mettre dans un pot commun mes billets et mes tickets de m�tro, les m�langer et repartir ainsi avec des num�ros de s�rie anonymis�s, par peur &lt;a href=&quot;http://www.eurobilltracker.com/&quot;&gt;d'�tre suivi&lt;/a&gt;, et puis cela me permettait d'�changer des empreintes &lt;a href=&quot;http://www.gnupg.org/(fr)/documentation/faqs.html#q1.1&quot;&gt;GnuPG&lt;/a&gt;.&lt;br /&gt;
&lt;br /&gt;
Bien s�r j'utilisais des &lt;a href=&quot;http://www.gnu.org/philosophy/free-sw.fr.html&quot;&gt;logiciels libres&lt;/a&gt;, car pourquoi ferais-je confiance � des logiciels propri�taires bo�tes noires, contenant potentiellement &lt;a href=&quot;http://www.transfert.net/a3504&quot;&gt;des portes d�rob�es&lt;/a&gt; ou des &lt;a href=&quot;http://fr.wikipedia.org/wiki/Spyware&quot;&gt;espiogiciels&lt;/a&gt;. Je ne communiquais qu'en &lt;a href=&quot;https://linuxfr.org&quot;&gt;https&lt;/a&gt;, mes courriels �taient tous chiffr�s, mes partitions aussi, et de toute fa�on mes remarques sur la m�t�o et le sexe oppos� ne circulaient que dans des images de gnous en utilisant de la &lt;a href=&quot;http://fr.wikipedia.org/wiki/St%C3%A9ganographie&quot;&gt;st�ganographie&lt;/a&gt;. Et je me croyais tranquille.&lt;br /&gt;
&lt;br /&gt;
C'�tait sans compter sur le d�ploiement de nouveaux ordinateurs &lt;a href=&quot;http://linuxfr.org/2003/01/10/10927.html&quot;&gt;�quip�s en standard de TPM&lt;/a&gt; (oui l'informatique dite � de confiance �, &lt;a href=&quot;http://www.lebars.org/sec/tcpa-faq.fr.html&quot;&gt;TCPA/Palladium&lt;/a&gt;, &lt;a href=&quot;http://ccomb.free.fr/TCPA_Stallman_fr.html&quot;&gt;ayez confiance&lt;/a&gt;, tout �a) qui �taient d�j� sur le march�. Et les &lt;a href=&quot;http://www.eff.org/deeplinks/archives/003835.php&quot;&gt;imprimantes qui se mettaient � bavasser&lt;/a&gt; aussi. Sans compter aussi que &lt;a href=&quot;http://www.edri.org/edrigram/number3.15/commission&quot;&gt;certains aimeraient bien collecter toutes les donn�es de trafic internet et t�l�phonique&lt;/a&gt; (le courrier postal n'int�resse personne...), en �voquant des &lt;a href=&quot;http://linuxfr.org/2005/07/31/19368.html&quot;&gt;questions de s�curit�&lt;/a&gt;, voire cr�er des &lt;a href=&quot;http://eucd.info/pr-2005-03-07.fr.php&quot;&gt;e-milices sur les r�seaux&lt;/a&gt; (de toute fa�on on me proposait d�j� de confier &lt;a href=&quot;http://www.schneier.com/blog/archives/2005/07/uk_police_and_e.html&quot;&gt;mes cl�s de chiffrement aux forces de police&lt;/a&gt;, sachant qu'&lt;a href=&quot;http://www.edri.org/edrigram/number3.13/backdoor&quot;&gt;ils savaient s'en passer si besoin&lt;/a&gt;). Ceci dit les &lt;a href=&quot;http://www.foruminternet.org/activites_evenements/lire.phtml?id=111&quot;&gt;d�bats sur la nouvelle carte d'identit� �lectronique en France&lt;/a&gt; avaient laiss� perplexe (identifiant unique, donn�es biom�triques, m�lange de l'officiel et du commercial, etc.).&lt;br /&gt;
&lt;br /&gt;
De son c�t� l'industrie de la musique et du cin�ma promettait des mesures techniques de protection pour d�cider si et quand et combien de fois je pourrais lire le DVD que j'avais achet�, et avec quel mat�riel et quel logiciel, en arguant des cataclysmes apocalyptiques et tentaculaires caus�s par des lyc�ens de 12 ans ; on me promettait m�me &lt;a href=&quot;http://rss.zdnet.fr/actualites/informatique/0,39040745,39251935,00.htm?xtor=1&quot;&gt;des identifiants uniques sur chaque disque et un blocage de la copie priv�e pourtant l�gale&lt;/a&gt;. Finalement on me proposait de b�n�ficier des puces d'identification par radio-fr�quences &lt;a href=&quot;http://fr.wikipedia.org/wiki/RFID&quot;&gt;RFID&lt;/a&gt; aux usages multiples : &lt;a href=&quot;http://yro.slashdot.org/yro/05/07/28/1456246.shtml?tid=158&amp;amp;tid=126&amp;amp;tid=193&quot;&gt;tra�age des �trangers&lt;/a&gt;, contr�le des papiers d'identit�, implantation sous-cutan�e...&lt;br /&gt;
&lt;br /&gt;
Bah il ne me restait plus qu'� aller poser devant les cam�ras dans la rue (&lt;a href=&quot;http://www.lemonde.fr/web/article/0,1-0@2-3224,36-677627@51-675643,0.html&quot;&gt;Paris&lt;/a&gt;, &lt;a href=&quot;http://www.ldh-toulon.net/imprimer.php3?id_article=798&quot;&gt;Londres&lt;/a&gt;, etc.), et � reprendre des &lt;a href=&quot;http://en.wikipedia.org/wiki/Tinfoil_hat&quot;&gt;pilules&lt;/a&gt;. Enfin �a ou essayer d'am�liorer les choses.&lt;br /&gt;
&lt;br /&gt;
� Nous avons neuf mois de vie priv�e avant de na�tre, �a devrait nous suffire. � (Heathcote Williams)&lt;br /&gt;
&lt;br /&gt;
� M�me les &lt;a href=&quot;http://unix.rulez.org/~calver/pictures/worldconspiracy.jpg&quot;&gt;parano�aques&lt;/a&gt; ont des ennemis. � (Albert Einstein)
    EOF
    output = <<-EOF
Le 17 ao�t 2005, la quasi totalit� de l'actuelle �quipe de d�veloppement du CMS Open Source Mambo a annonc�, dans une lettre ouverte � la communaut�, qu'elle pr�f�re abandonner Mambo suite � la cr�ation de la fondation du m�me nom.<br />
<br />
En effet, les d�veloppeurs pensent que l'orientation de Mambo doit �tre dict�e par les demandes de ses utilisateurs et les capacit�s des d�veloppeurs, or il semblerait que la Fondation Mambo soit con�ue pour accorder le contr�le � la soci�t� Miro, une conception qui rend la coop�ration entre la Fondation et la communaut� impossible.<br />
<br />
Dans les faits l'�quipe quitte donc la table de la fondation Mambo pour continuer de d�velopper le produit sous GPL, ce qui ressemble donc fort � un fork.


Le deuxi�me pique-nique du libre, organis� par Parinux est ouvert � tous les membres de la communaut� du logiciel libre et � leur famille dans le sens large du terme.<br />
<br />
Il est pr�vu pour le samedi 27 ao�t 2005 dans le Parc des Buttes-Chaumont. Rendez-vous de 12h00 � 12h15 � l'entr�e. Apr�s, il faudra trouver le groupe dans le parc. Un plan sur le site de Parinux devrait vous y aider.<br />
<br />
Les organisateurs vous demandent d'apporter quelque chose � boire et � manger et si vous le voulez, une couverture, ainsi que vos ballons de foot, de volley, p�tanque, badminton, cerf-volant, etc.

 Comme � son habitude - m�me si �a a pris un peu plus de temps que pr�vu depuis l'annonce de D�cembre 2000 - John Carmack peut aujourd'hui fournir le moteur du jeu <a href="http://fr.wikipedia.org/wiki/Quake_3">Quake 3</a> en GPL. Il est maintenant officiellement disponible sur les ftp de id software comme annonc� par linuX-gamers.<br />
<br />
John Carmack avait effectu� la semaine derni�re � QuakeCon 2005 l'annonce de "cette disponibilt� des sources sous une semaine". Quake III rejoint ainsi les Quake I et II dont le moteur est GPL depuis quelques temps, pour la plus grande joie des amateurs de jeux FPS (First Person Shooter ou <a href="http://fr.wikipedia.org/wiki/Jeu_de_tir_subjectif">jeu de tir subjectif en 3D</a> ou encore Quake-like).<br />
<br />
Il y a quelques temps, InternetActu a aussi effectu� une synth�se des raisons d'avoir des jeux libres (dont Nexuiz bas� sur quake1) montrant l'avancement des r�flexions sur le sujet.

    Vous en avez r�v�, vous l'avez r�clam�e... Elle est l� : <br />
<br />
LA d�p�che cin�ma sur le tout premier film de Garth Jennings : H2G2 <b>H</b>itch <b>H</b>icker's <b>G</b>uide to the <b>G</b>alaxy, en fran�ais : H2G2 Le Guide du Voyageur Galactique.<br />
<br />
Ce film est - comme tout bon geek qui se respecte le sait - l'adaptation au cin�ma d'une �mission radiophonique cr��e par Douglas Adams. Entre temps, on a eu le droit � cinq romans (constituant une trilogie...), une s�rie TV, un jeu vid�o.<br />
<br />
Mais je m'�gare : pour r�sumer le film (mais encore une fois est-ce bien l� peine ?), on suit donc les p�r�grinations intergalactiques du terrien Arthur Dent, apr�s que la terre a �t� ray�e du syst�me solaire. Celui-ci est accompagn� du pr�sident de la galaxie, de Ford Prefect, un ami extraterrestre en provenance d'une petite plan�te pr�s de B�telgeuse, de sa petite amie qui l'a l�ch� quelques heures apr�s l'avoir rencontr�, et de Marvin, un robot d�pressif.<br />
<br />
Et tout �a, pour quoi me demanderez-vous ? Mais voyons, trouver la question ultime de la vie, l'univers et tout le reste.

    Les deux grands constructeurs ont mis � jour r�cemment leurs pilotes propri�taires pour GNU/Linux (pour les architectures support�es).<br />
<br />
ATI : Sortie le 18/08 de la version 8.16.20 pour X86 et X86-64<br />
Une grosse mise � jour pour le constructeur canadien :<br />
Au menu :<br />
<ul><br />
<li>Am�lioration des performances</li><li>Support du noyau 2.6.12</li><li>Support de GCC 4.0</li><li>Correction de certains bugs :<br />
<ul><br />
 <li>R�solution des probl�mes syst�mes avec HDTV et les gros fichiers vid�os.</li> <li>Le curseur souris n'appara�t plus sur les deux �crans � la fois en multi-t�te.</li><li>Le panoramique sur le deuxi�me �cran est maintenant disponible en utilisant les pseudo-couleurs et le mode clone.</li> <li>Les machines sous Red Hat Enterprise Linux workstation 4 Update 1 et poss�dant 4 Go ou plus de m�moire n'ont plus de probl�me lors du chargement du pilote.</li> <li>Le support de l'Overlay est disponible sur les machines 64 bits</li> <li>Des fuites m�moires pour PCIe ont �t� corrig�s.</li><br />
</ul><br />
</li></ul><br />
<br />
NVIDIA : le 09/08 sortait la version 1.0-7676 pour X86 et AMD64<br />
Ce pilote n'est qu'un correctif du pr�c�dent, il r�gle le probl�me d'horloge pour les GeForce 7800 GTX (donc inutile pour tous ceux qui n'ont pas cette carte).

Le 17 ao�t 2005 est sorti sur vos grands �crans le dernier film de Michael Bay : The Island. (ndla : L'�le).<br />
<br />
Disons le tout de suite, vous ne verrez pas vraiment une �le paradisiaque avec plage de sable fin et cocotiers � perte de vue.<br />
Non, car l'heure est grave : un cataclysme a ravag� la plan�te, qui se trouve maintenant contamin�e.  <br />
<br />
Heureusement, certaines personnes survivent et sont ramen�es dans une colonie ferm�e o� vivent nos deux h�ros, incarn�s respectivement par  Ewan McGregor et  Scarlett Johansson.<br />
Pour illuminer une vie qui serait trop d�sesp�rante, chaque personne participe � une loterie, qui permet � son heureux gagnant de quitter la colonie pour une fabuleuse �le (non contamin�e), o� la vie est plus douce.<br />
<br />
Mais bient�t, notre cher Ewan commence � se poser des questions et va d�couvrir la r�alit� terrifiante de The Island ....

    Un long article de The Register revient sur le <i>"Sun's Linux killer"</i>, � savoir Solaris 10. Le but de l'auteur est davantage de r�aliser un compte-rendu d'utilisation qu'un comparatif, il n'y a notamment (et d�lib�r�ment) pas de benchmark qui pourraient �tayer les dires de l'auteur (Thomas C Green). Il faut donc garder en t�te le c�t� parfaitement subjectif de l'article.<br />
<br />
L'auteur souligne pour commencer que si, actuellement et sur la cible vis�e (les PC), GNU/Linux est loin devant, Sun peut se donner les moyens de rattraper son retard ... s'il en a le d�sir.<br />
<br />
Pour r�sumer les points forts de Solaris sont :<ul><li>la maturit� d'Unix, le syst�me est tout particuli�rement stable et il est difficile de le faire s'�crouler.</li><li>la rapidit� (subjectif)</li><li>la qualit� de <a href="http://opensolaris.org/os/community/dtrace/">DTrace</a></li><li>les zones virtuelles (<i>containers</i>) qui permettent de g�rer plus finement les ressources allou�es aux programmes</li><li>c'est Sun, entendre par l� que �a passera toujours mieux aupr�s d'un DSI de savoir qu'il y a le support de Sun derri�re</li></ul><br />
Les points faibles sont :<ul><li>la phase d'installation n'est pas meilleure qu'une bonne distribution GNU/Linux</li><li>le support du mat�riel limit�, l'exemple de la tr�s r�pandue SBLive est parlant.</li><li>les choix dans les logiciels propos�s (subjectif on vous a dit)</li><li>la jeunesse globale du projet et le c�t� commercial qui rebute encore la communaut�</li></ul><br />
Pour conclure, Solaris 10 est plus un bon concurrent en devenir plut�t qu'un <i>"GNU/Linux killer"</i> cependant il y a de bonnes id�es dans le syst�me qu'il conviendrait d'�tudier de pr�s.

    J'avais d�cid� de ne plus utiliser mon <a href="http://www.rfi.fr/actufr/articles/062/article_34098.asp">t�l�phone</a> et surtout pas mon mobile qui peut fournir <a href="http://www.transfert.net/a4879">ma position en continu</a>. J'avais banni les cartes de fid�lit� des supermarch�s qui permettaient de collecter les informations sur mes go�ts et de les revendre. J'�vitais de m�me les sondages divers commerciaux. Je me disais qu'en payant en liquide (avec un <a href="http://www.liberation.fr/page.php?Article=315139">risque de contrefa�on sur les billets</a> certes) et en n'utilisant pas <a href="http://www.lexpansion.com/art/2661.80555.0.html">de pass dans le m�tro</a>, je pr�serverais un peu de ma libert�. Poussant le raisonnement au bout, j'avais d�cid� d'organiser r�guli�rement des br�ves rencontres avec des inconnus pour mettre dans un pot commun mes billets et mes tickets de m�tro, les m�langer et repartir ainsi avec des num�ros de s�rie anonymis�s, par peur <a href="http://www.eurobilltracker.com/">d'�tre suivi</a>, et puis cela me permettait d'�changer des empreintes <a href="http://www.gnupg.org/(fr)/documentation/faqs.html#q1.1">GnuPG</a>.<br />
<br />
Bien s�r j'utilisais des <a href="http://www.gnu.org/philosophy/free-sw.fr.html">logiciels libres</a>, car pourquoi ferais-je confiance � des logiciels propri�taires bo�tes noires, contenant potentiellement <a href="http://www.transfert.net/a3504">des portes d�rob�es</a> ou des <a href="http://fr.wikipedia.org/wiki/Spyware">espiogiciels</a>. Je ne communiquais qu'en <a href="https://linuxfr.org">https</a>, mes courriels �taient tous chiffr�s, mes partitions aussi, et de toute fa�on mes remarques sur la m�t�o et le sexe oppos� ne circulaient que dans des images de gnous en utilisant de la <a href="http://fr.wikipedia.org/wiki/St%C3%A9ganographie">st�ganographie</a>. Et je me croyais tranquille.<br />
<br />
C'�tait sans compter sur le d�ploiement de nouveaux ordinateurs <a href="http://linuxfr.org/2003/01/10/10927.html">�quip�s en standard de TPM</a> (oui l'informatique dite � de confiance �, <a href="http://www.lebars.org/sec/tcpa-faq.fr.html">TCPA/Palladium</a>, <a href="http://ccomb.free.fr/TCPA_Stallman_fr.html">ayez confiance</a>, tout �a) qui �taient d�j� sur le march�. Et les <a href="http://www.eff.org/deeplinks/archives/003835.php">imprimantes qui se mettaient � bavasser</a> aussi. Sans compter aussi que <a href="http://www.edri.org/edrigram/number3.15/commission">certains aimeraient bien collecter toutes les donn�es de trafic internet et t�l�phonique</a> (le courrier postal n'int�resse personne...), en �voquant des <a href="http://linuxfr.org/2005/07/31/19368.html">questions de s�curit�</a>, voire cr�er des <a href="http://eucd.info/pr-2005-03-07.fr.php">e-milices sur les r�seaux</a> (de toute fa�on on me proposait d�j� de confier <a href="http://www.schneier.com/blog/archives/2005/07/uk_police_and_e.html">mes cl�s de chiffrement aux forces de police</a>, sachant qu'<a href="http://www.edri.org/edrigram/number3.13/backdoor">ils savaient s'en passer si besoin</a>). Ceci dit les <a href="http://www.foruminternet.org/activites_evenements/lire.phtml?id=111">d�bats sur la nouvelle carte d'identit� �lectronique en France</a> avaient laiss� perplexe (identifiant unique, donn�es biom�triques, m�lange de l'officiel et du commercial, etc.).<br />
<br />
De son c�t� l'industrie de la musique et du cin�ma promettait des mesures techniques de protection pour d�cider si et quand et combien de fois je pourrais lire le DVD que j'avais achet�, et avec quel mat�riel et quel logiciel, en arguant des cataclysmes apocalyptiques et tentaculaires caus�s par des lyc�ens de 12 ans ; on me promettait m�me <a href="http://rss.zdnet.fr/actualites/informatique/0,39040745,39251935,00.htm?xtor=1">des identifiants uniques sur chaque disque et un blocage de la copie priv�e pourtant l�gale</a>. Finalement on me proposait de b�n�ficier des puces d'identification par radio-fr�quences <a href="http://fr.wikipedia.org/wiki/RFID">RFID</a> aux usages multiples : <a href="http://yro.slashdot.org/yro/05/07/28/1456246.shtml?tid=158&amp;tid=126&amp;tid=193">tra�age des �trangers</a>, contr�le des papiers d'identit�, implantation sous-cutan�e...<br />
<br />
Bah il ne me restait plus qu'� aller poser devant les cam�ras dans la rue (<a href="http://www.lemonde.fr/web/article/0,1-0@2-3224,36-677627@51-675643,0.html">Paris</a>, <a href="http://www.ldh-toulon.net/imprimer.php3?id_article=798">Londres</a>, etc.), et � reprendre des <a href="http://en.wikipedia.org/wiki/Tinfoil_hat">pilules</a>. Enfin �a ou essayer d'am�liorer les choses.<br />
<br />
� Nous avons neuf mois de vie priv�e avant de na�tre, �a devrait nous suffire. � (Heathcote Williams)<br />
<br />
� M�me les <a href="http://unix.rulez.org/~calver/pictures/worldconspiracy.jpg">parano�aques</a> ont des ennemis. � (Albert Einstein)
    EOF
    assert_equal(output, input.unescape_html)
  end

  def test_unescape_bmc
    input = <<-EOF
So MIT&#39;s 
&lt;a href=&quot;http://www.techreview.com/&quot;&gt;Technology Review&lt;/a&gt; has named me as one of their
&lt;a href=&quot;http://www.technologyreview.com/articles/05/10/issue/feature_tr35.asp&quot;&gt;TR35&lt;/a&gt; -- the top 35 innovators under the age of thirty-five.  It&#39;s a great honor, especially because the other
honorees are &lt;i&gt;actually&lt;/i&gt; working on things like
&lt;a href=&quot;http://www.wi.mit.edu/research/fellows/brummelkamp.html&quot;&gt;cures for cancer&lt;/a&gt;
and
&lt;a href=&quot;http://www.pw.utc.com/shock-system/popsci.html&quot;&gt;rocket science&lt;/a&gt; -- domains
that I have known only as rhetorical flourish.
Should you like to hear me make a jackass out of myself on the subject, you might
want to check out
&lt;a href=&quot;http://blogs.sun.com/roller/page/rgiles&quot;&gt;Richard Giles&lt;/a&gt;&#39;s
&lt;a href=&quot;http://blogs.sun.com/roller/page/rgiles?entry=i_o_podcast_0003_bryan&quot;&gt;latest I/O podcast&lt;/a&gt;,
in which he interviewed me about the award.
    EOF

    output = <<-EOF
So MIT's 
<a href="http://www.techreview.com/">Technology Review</a> has named me as one of their
<a href="http://www.technologyreview.com/articles/05/10/issue/feature_tr35.asp">TR35</a> -- the top 35 innovators under the age of thirty-five.  It's a great honor, especially because the other
honorees are <i>actually</i> working on things like
<a href="http://www.wi.mit.edu/research/fellows/brummelkamp.html">cures for cancer</a>
and
<a href="http://www.pw.utc.com/shock-system/popsci.html">rocket science</a> -- domains
that I have known only as rhetorical flourish.
Should you like to hear me make a jackass out of myself on the subject, you might
want to check out
<a href="http://blogs.sun.com/roller/page/rgiles">Richard Giles</a>'s
<a href="http://blogs.sun.com/roller/page/rgiles?entry=i_o_podcast_0003_bryan">latest I/O podcast</a>,
in which he interviewed me about the award.
    EOF
    assert_equal(output, input.unescape_html)
  end

  def test_unescape_vnoel
    input = <<-EOF
&lt;div&gt;How are you supposed to trust these guys ?&lt;img src=&quot;http://members.cox.net/vnoel/weblog/uploaded_images/Screenshot-Flight%20Details-798819.png&quot; /&gt;
&lt;/div&gt;
    EOF

    output = <<-EOF
<div>How are you supposed to trust these guys ?<img src="http://members.cox.net/vnoel/weblog/uploaded_images/Screenshot-Flight%20Details-798819.png" />
</div>
    EOF
    assert_equal(output, input.unescape_html)
  end

  def test_unescape_hadess
    input = <<-EOF
Yay! Got &lt;a href=&quot;http://pilot-link.org/&quot;&gt;pilot-link&lt;/a&gt; to sync over Bluetooth, without the crappy 'Set up a PPP server' bit. Now to download &lt;a href=&quot;http://palmsource.palmgear.com/index.cfm?fuseaction=software.showsoftware&amp;prodID=52957&quot;&gt;BtSync&lt;/a&gt;.
    EOF

    output = <<-EOF
    EOF
    assert_equal(output, input.text2html)
  end

end
