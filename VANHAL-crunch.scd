

Require("teckDelay");

(
Pdef(\notes, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, 4 + [0, 1, 1.01, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1], inf).durStep(24),
        3,
        Pseq([-1, -2], inf).durStep(24),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, 6], inf).durStep(48),
)));

Pdef(\notes2, PS(Pbind(
    \scale, Scale.hexSus,
    \octave, 2 + [0, 2, 1.01, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1, 4], inf),
        Prand([3, 4, 7], inf),
        Pseq([-1, -2, 6, -2], inf),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, 6, 3, -2], inf),
).durStep(8)));


Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    // \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    \buf, Prand([
        // SAMP("zoom recordings/greece/SPTL003.WAV", channels:1)[0],    
        SAMP("photek/full/*", channels:1)[0],
        SAMP("photek/full/*", channels:1)[1],
        SAMP("photek/full/*", channels:1)[2]
    ], inf),    
    
    \dur, Pxstep(
        1 * Prand([5, 3, 2.4, 1.7, 0.2, 0.1, 0.54342, 0.7643, 0.123, 0.05], inf),
        3
    ),
    \dur, Pbjorklund2(9, 16, inf, Pseq([2, 4], inf).durStep(2)) / 8,
    \strum, Pwnrand([0, 3/8], [9, 2], inf),
    \legato, Pwhite(1.2, 2),
    
    \amp, 14.dbamp * [1, 1, 1, 1],
    \pan, Pwhite(-1, 1),
    
    \pos, Pmod(
        {
            var rate, trig;
            
            trig = \trig.tr(0);
            rate = \rate.kr(2);
            
            trig = Decay.kr(trig, 6);
            
            SinOsc.ar(trig * rate + [0, 1/24].resamp1(4)).range(
                // "2:08".asSecs,
                // "2:54".asSecs
                "0:08".asSecs,
                "1:54".asSecs
            )
            + (0)
            + LFTri.ar(1/256).range(0, 8)
        },
        \trig, 1,
        \rate, Pmod({
            LFDNoise3.ar(1/5).linexp(-1, 1, 1/160, 1/20)
        })
    ).expand,
    
    \trigRate, { ~detunedFreq.value * 1 },
    
    \density, Ptuple(
        Pwhite(0.0, 1.0).lincurve(0, 1, 6, 150, 5).trace ! 4
    ),
    
    \ampEnv, {
        `(Env.perc(0.0001, ~sustain.value, curve:-12 * [-1, 1]))
    },
    \env, 0.02,
    
    \trig, 0,
    
    \grainRate,  Pmod({
        (
            // [0, 4, -12, 0]
            [0, -0.212, 0.234, 3]
            + 4.collect {
                Env.sine(0.5).ar(gate:Dust.ar(0.7))
            }.linlin(0, 1, 0, 24)
            + 4.collect {
                Env.sine(0.5).ar(gate:Dust.ar(0.5))
            }.linlin(0, 1, 0, -24)
        ).midiratio
    }),
    
    \finish, {
        // ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
    }
) <> Pdef(\notes));

Pdef(\delay, Pmono(
    \grainDelay2,
    \parentType, \grainDelay2,
    
    \dur, Prand([1/2, 3, 4, 5], inf),
    
    \finish, {
        ~in = ~in.value;
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
        ~grainRate = ~grainRate.value;
        ~delayRound = ~delayRound.value;
    },
    
    \delay, Pmod({
        var flux = LFDNoise3.ar(1/4).exprange(
            1/164,
            1/8
        );
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/18))
        }
    }).expand,
    \delayV, Pmod({
        1 / LFDNoise3.ar(1/6).lincurve(-1, 1, 16, 250, -5)
    }),
    
    // \octave, 2,
    // \degree, Pseq([0, -1], inf).durStep(16) + (1 * [0, 2.024, 5.03, 0.0253]),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 1,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            40.3 * roundOff * LFDNoise3.ar(1/8).abs.lag(0.7 * [0.2, 1.0, 0.4, 0.0])
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 16,
    \density, Pmod({
        SinOsc.ar(LFDNoise3.ar(1/2).exprange(1/2, 28), [0, 0.1].resamp1(4))
            .lincurve(-1, 1, 4, 300, 2).poll
    }).expand,
    
    \grainRate, Pmod({
        1.collect {
            var trig = Dust.ar(0.52);
            (
                Env.sine(4).ar(gate:trig)
                    * LFDNoise3.ar(1/4).range(-0.1, 0.1)
            ).midiratio
        }
    }).expand,
    \grainRateV, 0.00012,
    // \grainRate, { (~detunedFreq.value.cpsmidi - 28).midiratio.postln },
    
    \feedAmp, -46.dbamp,
    \feedDist, Pmod({
        14 + Env.perc(2, 4, curve:\sine).ar(gate:Dust.ar(0.4)).linlin(0, 1, 0, 25)
    }),
    
    \filtLo, 20,
    \filtHi, Pexprand(2000, 19900).durStep(12),
    \filtLag, 12,
    
    \pan, Pmod({
        4.collect {
            0.8 * LFDNoise3.ar(1/4).range(-1, 1)
        }
    }),
    \panV, 0.03,
    
    \amp, -20.dbamp,
    \dryAmp, 10.dbamp
) <> Pdef(\notes2));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    
    \inEnv, 0,
    
    \dist, 0,
    \inAmp, -30.dbamp,
    \amp, -12.dbamp,
    \feed, -6.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, -12.dbamp,
));

Pdef(\vanCompress,
    Pdef(\compressor)
).set(
    \c, ~vanCompress = ~vanCompress ?? {
        ControlValueEnvir(BusControlValue)
});

// Pdef(\player).clear;
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
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                
                                                                                                                                                    
                                                                                                                                                        
                                                                                                                                                            
                                                                                                                                                                
                                                                                                                                                                    
                                                                                                                                                                        
                                                                                                                                                                            
                                                                                                                                                                                
                                                                                                                                                                                    
                                                                                                                                                                                        
                                                                                                                                                                                            
                                                                                                                                                                                                
                                                                                                                                                                                                    
                                                                                                                                                                                                        
                                                                                                                                                                                                            
                                                                                                                                                                                                                
                                                                                                                                                                                                                    
                                                                                                                                                                                                                        
                                                                                                                                                                                                                            
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                        