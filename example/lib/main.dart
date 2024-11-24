import 'package:flutter/material.dart';
import 'package:blurhash_shader/blurhash_shader.dart';

const testHash = [
  // 4 * 3
  r"LEHLk~WB2yk8pyo0adR*.7kCMdnj",
  r"LGF5]+Yk^6#M@-5c,1J5@[or[Q6.",
  r"L6PZfSi_.AyE_3t7t7R**0o#DgR4",
  r"LEHLh[WB2yk8pyoJadR*.7kCMdnj",
  r"L7BN_nhx00}y0K:j-VC+v7PTxIwc",
  r"LePN@4oeIVs:_L$*M{s:drj]NGW;",
  r"LEA30Mcr07mp0USz}:n%+JRRENo]",
  r"LNNcMs[T7h=E3ZS$R+FL3ES#nONx",
  r"LNO:Oy-raO9E~XSzyCrrUGMxeWpI",
  r"LK8r]]xhQ;QWwnV.jIa+n;XMoatT",
  r"LmLDoCNaEyrXT_NZVts,_MxDjZNG",
  r"LPQ]Ax%yyqD*-yt2Q,s.*GXmVZs:",
  r"LRQt=aD48{4;-o$*$MozNF*IRjU_",
  r"LFLga_DQ01o}Y+4;}@o}Q9=YIVs8",
  r"LKM=eJ}E0N0yO;sk70og9vM|IBxG",
  r"LqNAMD%K?dIUECa*R7s%gNi{RPWF",
  r"LQFi0*}Yn+Rk+a%KoyWAk=Rjs9WB",
  r"LUHnsi~pT0o}^+D*D%V@tlIowcxu",
  r"LDKA{Q}?yC9GRK%29#oz619v};Iq",
  r"LMMQn__4I]%N_LIAs,R+~nNFM|xt",
  r"LGK^EFx]01%100M{a1V@00IV~BoM",
  r"LaP6djsW-gkBYzX7tmjGnNn%$7bG",
  r"LLN+n8?Z9I+b;AS*NaSv|4R8OmK1",
  r"LZP}GEs8{JRk-$kBIof+nKW=F{t6",
  r"LEF;i_Ip57j[}@s:9uEL9a^j^jNH",
  r"LKP}[eDl*n}wDm5}-qr^aepYtl%L",
  r"LWJ8^5ofIQoy_LWYj;RiS@V{xbWZ",
  r"LZF97dOrLJwucNaKt7b^HVr=rET0",
  r"LHGaCUK5^+o$IWI;R%Rop3NHO8NI",
  r"LMJt#WI]?wIU4pD*M{-=ESIB$~Ip",

  // 10 * 6
  r"rLLXc8J7.Ao~9FIAkXITR,_3=|soM_M{bca#kCRj.9adD%IUs,%gi^R*n%-;RjMxtRbwRPkXofkCR3bbnO%Mx]MxRjazWXO@jFtSRjjYbbR5ozs:",
];

enum BlurType {
  shader,
  shaderToImage,
  fbhWidget,
  fbhImage,
}

void main() async {
  await BlurHash.loadShader();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  String hash = 'LEHLk~WB2yk8pyo0adR*.7kCMdnj';
  int hashIndex = 0;

  late final TextEditingController controller =
      TextEditingController(text: hash);

  static String? getErrorMsg(String blurHash) {
    try {
      BlurHash.decode(blurHash);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  isValid(String blurHash) {
    try {
      BlurHash.decode(blurHash);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BlurHash Shader Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: BlurHash(hash),
                    ),
                    const SizedBox(width: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeInOutCubicEmphasized,
                      decoration: BlurHashDecoration(
                        hash,
                        shape: const OvalBorder(
                          side: BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      height: 200,
                      width: 200,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter a BlurHash',
                    errorText: getErrorMsg(controller.text),
                  ),
                  controller: controller,
                  onChanged: (hash) {
                    setState(() {
                      if (isValid(hash)) {
                        this.hash = hash;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: () {
                      // testHash
                      final newHash = testHash[++hashIndex % testHash.length];
                      setState(() {
                        hash = newHash;
                      });
                      // Future(() {
                      //   controller.text = newHash;
                      // });
                    },
                    child: Text("Random")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
