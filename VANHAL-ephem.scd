

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
    \octave, 3 + [0, 1, 1.01, 0],
    \degree, 0 + Ptuple([
        Pseq([0, 1, 4], inf),
        Prand([3, 4, 7], inf),
        Pseq([-1, -2, 6, -2], inf),
        0
    ]).durStep(16),
    \degree, Pkey(\degree) + Pseq([0, 6, 3, -2], inf).durStep(8),
)));

Pdefn(\fade, PS(
    // Pseg([0.5, 1, 0], 60 * [12, 4])
    Pseg([0.0, 1, 1, 0], 60 * [12, 2, 4])
));



Pdef(\van, Pbind(
    // \grainSampler_2ch,
    \instrument, \grainSampler_2ch,
    \buf, SAMP("vanhalen/mixdown.wav", channels:1)[0],    
    \fade, Pdefn(\fade),
    
    \dur, Pxfade([
        12,
        Pxstep(
            1 * Prand([5, 3, 2.4, 1.7, 0.2, 0.1, 0.54342, 0.7643, 0.123, 0.05], inf),
            3
        ) + Pwnrand([0, 3, 8], [40, 1, 1], inf),
        Pseg([1/20, 1/2, 1/20], [16, 4], \sine).repeat
    ], Pkey(\fade).lincurve(0, 1, 0, 2, -3), \expBlend),
    \strum, Pxfade(
        [0, 0, 1/4, 0],
        Pkey(\fade) * 3, 
        \blend
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
        Pwhite(0.0, 1.0).lincurve(0, 1, 6, 220, 3) ! 4
    ),
    
    \attack, Pxfade([
        0.2,
        0.02,
        0.001
    ], Pkey(\fade).lincurve(0, 1, 0, 2, 6), \random),
    \envCurve, Pxfade([-8, -16, -20], Pkey(\fade) * 3, \blend),
    \ampEnv, {
        var attack;
        var sustain = ~sustain.value;
        var curve = ~envCurve.value;
        
        attack = blend(0.001, ~attack.value, ~fade.value);
        
        `(Env.perc(attack * sustain, (1 - attack) * sustain, curve:curve * [-1, 1]))
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
            1/2
        );
        
        4.collect {
            flux.lag(LFDNoise3.kr(1/16).range(0, 1/8))
        }
    }).expand,
    \delayV, Pmod({
        1 / LFDNoise3.ar(1/6).exprange(8, 400)
    }),
    
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, 0.5,
    \delayRoundOffset, Pmod(
        {
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            [-1, 1] * roundOff * LFDNoise3.ar(1/2).abs.lag(0.7 * [0.2, 1.0, 0.4, 0.0])
                .linlin(-1, 1, 0.05, 2)
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
    \grainRateV, Pexprand(0.000312, 0.013).durStep(4),
    \grainRateVLag, 6,
    // \grainRate, { (~detunedFreq.value.cpsmidi - 28).midiratio.postln },
    
    \feedAmp, -49.dbamp,
    \feedDist, Pmod({
        26 + Env.perc(2, 4, curve:\sine).ar(gate:Dust.ar(0.4)).linlin(0, 1, 0, 25)
    }),
    
    \filtLo, 20,
    \filtHi, Pexprand(2000, 19900).durStep(12),
    \filtLag, 24,
    
    \pan, Pmod({
        4.collect {
            0.8 * LFDNoise3.ar(1/4).range(-1, 1)
        }
    }),
    \panV, 0.1,
    
    \amp, -20.dbamp,
    \dryAmp, -30.dbamp
) <> Pdef(\notes2));

Pdef(\teckDelay, Pmono(
    \teckDelay,
    
    \inEnv, 0,
    
    \dist, 0,
    \inAmp, -30.dbamp,
    \amp, -12.dbamp,
    \feed, -12.dbamp,
    \dryAmp, 0.dbamp,
    \wetAmp, 6.dbamp,
    
    \reverbAmp, -20.dbamp,
    \kickAmp, -25.dbamp,
    \crushAmp, -20.dbamp,
    
    \delayMult, 1
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
        // ~delay.out = 0;
        ~teckDelay.in = ~delay;
        ~vanCompress.in = ~teckDelay;
        ~vanCompress.out = 0;
    }, Pdef.all)
))).play
)


~vanCompress.gui
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                
                                                                                                                                                    
                                                                                                                                                        
                                                                                                                                                            
                                                                                                                                                                
                                                                                                                                                                    
                                                                                                                                                                        
                                                                                                                                                                            
                                                                                                                                                                                
                                                                                                                                                                                    
                                                                                                                                                                                        
                                                                                                                                                                                            
                                                                                                                                                                                                
                                                                                                                                                                                                    
                                                                                                                                                                                                        
                                                                                                                                                                                                            
                                                                                                                                                                                                                
                                                                                                                                                                                                                    
                                                                                                                                                                                                                        
                                                                                                                                                                                                                            
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                    