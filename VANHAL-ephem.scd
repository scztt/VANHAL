

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
    \octave, 4 + [0, 2, 1.01, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1, 4], inf),
        Prand([3, 4, 7], inf),
        Pseq([-1, -2, 6, -2], inf),
        0
    ]),
    \degree, Pkey(\degree) + Pseq([0, 6, 3, -2], inf),
)));


Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    
    \dur, Pxstep(
        1 * Prand([5, 3, 2.4, 1.7, 0.2, 0.1, 0.54342, 0.7643, 0.123, 0.05], inf),
        3
    ),
    \legato, 1.4,
    
    \amp, -6.dbamp * [1, 1, 1, 1],
    \pan, Pwhite(-1, 1),
    
    \pos, Pmod(
        {
            var rate, trig;
            
            trig = \trig.tr(0);
            rate = \rate.kr(2);
            
            trig = Decay.kr(trig, 6);
            
            SinOsc.ar(trig * rate + [0, 1/24].resamp1(4)).range(
                "2:08".asSecs,
                "2:54".asSecs
            )
            + (0)
            + LFTri.ar(1/128).range(0, 8)
        },
        \trig, 1,
        \rate, Pmod({
            LFDNoise3.ar(1/5).exprange(1/60, 1/12)
        })
    ).expand,
    
    \trigRate, { ~detunedFreq.value * 2 },
    
    \density, Ptuple(
        Pwhite(0.0, 1.0).lincurve(0, 1, 6, 120, 3) ! 4
    ),
    
    \ampEnv, {
        `(Env.perc(0.0001, ~sustain.value, curve:-12 * [-1, 1]))
    },
    \env, 0.05,
    
    \trig, 0,
    
    \grainRate,  Pmod({
        (
            [0, 4, -12, 0]
            + 4.collect {
                Env.sine(1).ar(gate:Dust.ar(0.2))
            }.range(0, 24)
            + 4.collect {
                Env.sine(1).ar(gate:Dust.ar(0.2))
            }.range(0, -24)
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
            1/64,
            1/4
        );
        
        4.collect {
            DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/18))
        }
    }).expand,
    \delayV, Pmod({
        1 / LFDNoise3.ar(1/6).exprange(8, 600)
    }),
    
    // \octave, 2,
    // \degree, Pseq([0, -1], inf).durStep(16) + (1 * [0, 2.024, 5.03, 0.0253]),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 0.05,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            0.2 * roundOff * LFDNoise3.ar(1/2).abs.lag(0.7 * [0.2, 1.0, 0.4, 0.0])
        }, 
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, 60 * 16,
    \density, Pmod({
        SinOsc.ar(LFDNoise3.ar(1/2).exprange(1/2, 28), [0, 0.1].resamp1(4))
            .exprange(20, 600)
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
    \grainRateV, 0.003,
    // \grainRate, { (~detunedFreq.value.cpsmidi - 28).midiratio.postln },
    
    \feedAmp, -46.dbamp,
    \feedDist, Pmod({
        54 + Env.perc(2, 4, curve:\sine).ar(gate:Dust.ar(0.4)).linlin(0, 1, 0, 25)
    }),
    
    \filtLo, 20,
    \filtHi, Pexprand(2000, 19900).durStep(12),
    \filtLag, 24,
    
    \pan, Pmod({
        4.collect {
            0.8 * LFDNoise3.ar(1/4).range(-1, 1)
        }
    }),
    \panV, 0.4,
    
    \amp, -10.dbamp,
    \dryAmp, 0.dbamp
) <> Pdef(\notes2));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    
    \inEnv, 0,
    
    \dist, 0,
    \inAmp, -30.dbamp,
    \amp, -12.dbamp,
    \feed, -9.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 6.dbamp,
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
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                
                                                                                                                                                    
                                                                                                                                                        
                                                                                                                                                            
                                                                                                                                                                
                                                                                                                                                                    
                                                                                                                                                                        
                                                                                                                                                                            
                                                                                                                                                                                
                                                                                                                                                                                    
                                                                                                                                                                                        
                                                                                                                                                                                            
                                                                                                                                                                                                
                                                                                                                                                                                                    
                                                                                                                                                                                                        
                                                                                                                                                                                                            
                                                                                                                                                                                                                
                                                                                                                                                                                                                    
                                                                                                                                                                                                                        
                                                                                                                                                                                                                            
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                        