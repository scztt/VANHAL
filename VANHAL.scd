

Require("teckDelay");

(
Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, 16,
    \legato, 0.5,
    
    \amp, 0.dbamp * [1, 1, 1, 1],
    \pan, 0.5 * [-1, 1],
    
    \pos, Pmod(
        {
            |rate=2|
            SinOsc.ar(rate + [0, 1/24].resamp1(4)).range(
                "2:08".asSecs,
                "2:14".asSecs
            )
            + 1
            + LFTri.ar(1/128).range(0, 4)
        },
        \rate, Pmod({
            LFDNoise3.ar(1/40).exprange(1/4, 1/1)
        })
    ).expand,
    
    // \pos, Pmod(
    //     {
    //         var lfoRate = \lfoRate.kr(1);
    //         lfoRate = lfoRate + [0, 1/16].resamp1(4);
    
    //         LFTri.ar(1/64).range(
    //             "2:28".asSecs,
    //             "2:36".asSecs
    //         )
    //         + (
    //             \lfoScale.kr(1) * SinOsc.ar(lfoRate).range(-1, 1)
    //         )
    //     },
    //     \lfoRate, 0.7,
    //     \lfoScale, 0.2,
    
    // ).expand,
    
    \pos, Pmod(
        {
            var lfoRate = \lfoRate.kr(1);
            lfoRate = lfoRate + [0, 1/16].resamp1(4);
            
            LFTri.ar(1/256).range(
                // "5:48".asSecs,
                // "5:52".asSecs
                "6:03".asSecs,
                "6:12".asSecs
            )
            + (
                \lfoScale.kr(1) 
                    * SinOsc.ar(lfoRate).range(
                        -1, 
                        1
                    )
            )
        }, 
        \lfoScale, 0.02,
        \lfoRate, 1/8
    ).expand,
    
    // \posV, 1/20,
    // \posRound, Pmod({ 
    //     1 / LFDNoise3.ar(1/48).exprange(40, 700)
    // }),
    // \posRoundOffset, Pmod({
    //     0.3 * (1/400) * SinOsc.ar(1/48, [0, pi]).range(-1, 1)
    // }).expand,
    // \env, 0.05,
    \trigRate, { ~detunedFreq.value * 1 },
    \trigRateV, 0.001,
    \density, 200,
    // \amp, Pmod({
    //     var trig = Impulse.ar(1, [0, 1, 2, 3] / 4);
    //     Decay.ar(trig, 1.0).range(-60, 0).dbamp
    // }).expand,
    
    \ampEnv, `Env([0, 1, 0], [6, 8], \sine, releaseNode:1),
    
    \trig, 0,
    
    \scale, Scale.hexSus,
    \octave, 2 + [0, 0, 0, 0],
    \degree, 0 + [0, 3, 2, 0] + [0, 0.01].resamp1(4),
    \degree, Pkey(\degree) + Pseq([0, -4], inf).durStep(32),
    \grainRate, { (~detunedFreq.value.cpsmidi - 42).midiratio },
    
    // \grainRate, Pmod(
    //     {
    //         |freq=60|
    //         var note = freq.cpsmidi - 42;
    //         (
    //             note.lag(20) 
    //                 + SinOsc.ar(1/64, Rand(0, 0.04)).range(-0.2, 0.2)
    //         ).midiratio
    //     },
    //     \scale, Scale.hexSus,
    //     \octave, [3, 3, 3, 3],
    //     \degree, 5 + Pseq([
    //         [ 0, 0.01, 1.02545, 0.134],
    //         [ 0, 0.01, 1.02545, 0.134] - [0, 1],
    //         [-2, 1.00, 3.01,    6],
    //         [-2, 1.00, 3.01,    6] + [0, 4],
    //     ], inf).durStep(32).trace + [0, 1, -7, 4]
    // ),
    \filtLo, 20,
    \filtHi, Pmod({
        SinOsc.ar(1/256, 2 + [0, 0.2].resamp1(4) - (pi/2)).exprange(200, 1600)
    }),
    
    // \dur, 1,
    // \legato, 1,
));

Pdef(\delay, Pmono(
    \grainDelay2,
    \parentType, \grainDelay2,
    
    \finish, {
        ~in = ~in.value.postln;
    },
    
    // \delay, Pmod({
    //     var flux = SinOsc.ar(1/6).exprange(
    //         LFDNoise3.kr(1/64).exprange(1/500, 1/8),
    //         3/4
    //     );
    //     4.collect {
    //         DelayC.ar(flux, 1, LFDNoise3.kr(1/8).range(0, 1/32))
    //     }
    // }).expand,
    \delay, Pmod({
        var flux = LFDNoise3.ar(1/4).exprange(
            1/12,
            2
        ).reciprocal;
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/32))
        }
    }).expand,
    \delayV, Pmod({
        1 / SinOsc.ar(1/24).exprange(20, 200)
    }),
    
    \scale, Scale.hexSus,
    \octave, 2,
    \degree, Pseq([0, -1], inf).durStep(16) + (1 * [0, 2.024, 5.03, 0.0253]),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 8,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            4.4 * roundOff * LFDNoise3.ar(1/4).lag(0.1 * [0.1, 1.0, 0.4, 0.0].scramble)
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 1,
    // \trigRateV, 0.03,
    \density, 120,
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.05);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/4).range(-0.5, 0.0)
            ).midiratio
        }
    }).expand,
    
    \feedAmp, -36.dbamp,
    // \feedDist, Pmod({ 
    //     SinOsc.kr(1/36, [0, pi].resamp1(4) - (pi/2)).lincurve(-1, 1, 0.5, 26, 8).poll 
    // }).expand,
    \feedDist, 1.4,
    \filtLo, 60,
    \filtHi, Pexprand(200, 5900).durStep(12),
    \filtLag, 24,
    
    \pan, [-0.8, 0.8].resamp1(4),
    \panV, 0.2,
    
    \amp, -12.dbamp,
    \dryAmp, -14.dbamp
));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    \amp, -16.dbamp,
    \inAmp, -6.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 10.dbamp,
    \inEnv, 0
));

Pdef(\vanCompress,
    Pdef(\compressor)
).set(
    \c, ~vanCompress = ~vanCompress ?? {
        ControlValueEnvir(BusControlValue)
});

Pdef(\player, Pio(Ppar(
    Pio.make({
        // ~van.out = 0;
        ~van.out = Pout(\delay, 2);
        ~delay.in = Pin(\delay, 2);
        ~teckDelay.in = ~delay;
        ~vanCompress.in = ~teckDelay;
        ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                