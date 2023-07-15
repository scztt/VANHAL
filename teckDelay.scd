(

SynthDef.fx(\teckDelay, {
    |in|
    var delays = DC.ar([0.1, 0.5, 0.7, 3, 3, 4, 3, 6, 8, 4.1]);
    var trig, crush, kickEnv, kickCurve;
    var rev = DC.ar([0, 0, 0]);
    
    trig = Impulse.ar(16) * Trig.ar(Impulse.ar(6/8), 0.5) * Trig.ar(Dust.ar(0.5), 1.5);
    
    crush = PlayBuf.ar(
        2,
        SAMP("zoom recordings/_incoming/greece/*")["spring"],
        startPos: Rand(0, 44100*60),
        loop: 1
    );
    
    crush = BandSplitter8.ar(crush, *Array.geom(7, 100, 2.2));
    
    kickEnv = PulseDivider.ar(
        trig, 
        TChoose.ar(trig, DC.ar([6, 8, 12]))
    );
    kickCurve = TRand.ar(0, 1, kickEnv).lincurve(0, 1, -8, 12, -3).lag(0.1);
    kickEnv = Env.perc(0.01, TRand.ar(0, 1, kickEnv).lincurve(0, 1, 2.5, 8, -4)).ar(gate:kickEnv);
    
    in = (0.dbamp * in) + (
        -0.dbamp * kickEnv * Formant.ar(
            kickEnv.lincurve(0, 1, 10, [96, 96.5, 40], kickCurve) ,
            kickEnv.lincurve(0, 1, 10, 120, kickCurve + 6),
            kickEnv.lincurve(0, 1, 0, 150, kickCurve + 8)
        ).sum
    );
    
    in = BandSplitter8.ar(in, *Array.geom(7, 100, 2.2)).collect({
        |in, i|
        var envTrig, bandTrig, crushBand, kickEnv;
        
        // in = in.tanh;
        
        bandTrig = Dust.ar(0.5);
        envTrig = trig * TWChoose.ar(trig, DC.ar([0, 1]), DC.ar([100, 1]), 1);
        
        crushBand = (12.dbamp * crush[i]) + (-14.dbamp * in);
        crushBand = crushBand + (
            LFDNoise3.ar(1).lincurve(-1, 1, -60, -4, 2).dbamp
                * Formant.ar(
                    (SinOsc.kr(1/8, Rand(0, 2), 0.3) + 26 + [0, 4, 6]).midicps[i % 3],
                    LFDNoise3.kr(1/3).exprange(20, 8000),
                    LFDNoise3.kr(1/2).exprange(10, 500),
                )
        );
        crushBand = crushBand * Env.perc(0.01, 1.8).ar(
            gate:PulseDivider.ar(
                trig, 
                TChoose.ar(trig, DC.ar([1, 2, 3, 4, 6, 5])) * 2,
                [0, 1, 2].choose
            )
        );
        
        crushBand = crushBand + (-10.dbamp * Pluck.ar(
            crushBand, ClipNoise.ar, 1, 
            (SinOsc.kr(1/8, Rand(0, 2), 0.3) + 22 + [0, 4, 6]).midicps[i % 3].reciprocal,
            0.1, 0.04
        ));
        crushBand = 16.dbamp * crushBand.collect {
            |crushBand|
            
            4.do {
                crushBand = BBandStop.ar(crushBand, LFDNoise3.ar(2).exprange(80, 9200), 0.2)
            };
            
            crushBand = PitchShift.ar(
                crushBand, 
                1/4, 
                LFDNoise3.ar(0.2).range(-12, 12).midiratio.lag(
                    LFDNoise3.ar(4).exprange(0.01, 1) * 0.2 * [1, 2, 3, 6, 8]
                ),
                timeDispersion: 0.0032
            ).mean;
        };
        crushBand = crushBand + (-6.dbamp * Pluck.ar(
            crushBand, ClipNoise.ar, 1, 
            (SinOsc.kr(1/16, Rand(0, 2), 0.6) + 23 + [0, 0.1, 0.2]).midicps[i % 3].reciprocal,
            TExpRand.ar(0.01, 0.6, trig).lag(0.02), 0.1
        ));
        
        in = blend(
            in,
            in * (0.2 + Env.perc(0.1, 0.6).ar(
                gate:PulseDivider.ar(
                    trig, 
                    TChoose.ar(trig, DC.ar([1, 3, 2, 6, 5])), 
                    [0, 1, 2].choose
            ))),
            \inEnv.kr(1)
        );
        
        in = (-2.dbamp * in) + crushBand;
        in = LeakDC.ar(in);
        
        in.assertChannels(2);
        in = in + in.feed({
            |in|
            in.assertChannels(2);
            in = LeakDC.ar(in);
            in = in.collect {
                |in|
                DelayC.ar(
                    in,
                    8,
                    TChoose.ar(bandTrig, delays).lag3(6 + (1 * [0.2, 0.5, 0.6, 0.7, 0.9].scramble)) / 2
                ).mean
            };
            
            // in = FreqShift.ar(in, SinOsc.kr(1/Rand(9, 10)).exprange(-0.02, 0.1));
            in = (1 * in) - (FreqShift.ar(in, SinOsc.kr(1/Rand(9, 10)).exprange(-0.02, 0.1)));
            in = -6.dbamp * in;            
        }).sum;
        
        3.do {
            |i|
            rev[i] = rev[i] + (
                LFDNoise3.ar(2).lincurve(-1, 1, -46, 0, -8).dbamp
                    * in
            );
        };
        
        in;
    }).sum;
    
    in = in + (-12.dbamp * (
        JPverb.ar(
            rev[0], 0.1, 0.5, 4
        )
        + JPverb.ar(
            rev[1], 0.5, 0.6, 0.3
        )
        + JPverb.ar(
            rev[2], 2.3, 0.2, 0.3
        )
    ));
    
    in.assertChannels(2);
}).add;
)
