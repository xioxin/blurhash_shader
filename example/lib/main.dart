import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blurhash_shader/blurhash_shader.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart' as fbh;

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

  BlurType useShaderType = BlurType.shader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showPerformanceOverlay: !kIsWeb,
      home: ColoredBox(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(top: kIsWeb ? 0 : 170),
          child: Scaffold(
            appBar: AppBar(
              title: switch (useShaderType) {
                BlurType.shader => const Text('🚀 package:blurhash_shader'),
                BlurType.shaderToImage =>
                  const Text('🚗 package:blurhash_shader (ToImage)'),
                BlurType.fbhWidget =>
                  const Text('🐢 package:flutter_blurhash (Widget)'),
                BlurType.fbhImage =>
                  const Text('🚗 package:flutter_blurhash (Image)'),
              },
              actions: [
                SegmentedButton(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      tooltip: "package:blurhash_shader",
                      value: BlurType.shader,
                      label: Text('🚀Shader'),
                    ),
                    ButtonSegment(
                      tooltip: "package:blurhash_shader",
                      value: BlurType.shaderToImage,
                      label: Text('🚗ShaderToImage'),
                    ),
                    ButtonSegment(
                      tooltip: "package:flutter_blurhash",
                      value: BlurType.fbhWidget,
                      label: Text('🐢fbh:Widget'),
                    ),
                    ButtonSegment(
                      tooltip: "package:flutter_blurhash",
                      value: BlurType.fbhImage,
                      label: Text('🚗fbh:Image'),
                    ),
                  ],
                  selected: {useShaderType},
                  onSelectionChanged: (v) {
                    setState(() {
                      useShaderType = v.first;
                    });
                  },
                )
              ],
            ),
            body: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 80,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 4 / 3,
              ),
              itemBuilder: (BuildContext context, int index) {
                final code = testHash[index % testHash.length];
                return switch (useShaderType) {
                  BlurType.shader => BlurHash(code),
                  BlurType.shaderToImage =>
                    Image(image: BlurHashImageProvider(code), fit: BoxFit.fill),
                  BlurType.fbhWidget => fbh.BlurHash(hash: code),
                  BlurType.fbhImage =>
                    Image(image: fbh.BlurHashImage(code), fit: BoxFit.fill),
                };
              },
            ),
          ),
        ),
      ),
    );
  }
}
