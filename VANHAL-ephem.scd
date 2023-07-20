

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
    \octave, 2 + [0, 1, 1.01, 0],
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
    Pseg([0, 1, 1, 0], 60 * [12, 2, 4])
));


////////////////////////////////////////////////////////////////////////////////////////////////////
// SAMPLER
////////////////////////////////////////////////////////////////////////////////////////////////////\

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
    
    \strum, Pxfade([
        0,
        Pseg([0, 0, 1/4, 0], [8, 8, 4], \sine).repeat
    ], Pkey(\fade), \blend),
    
    \legato, Pxfade([1.1, 4], Pkey(\fade), \blend),
    
    \amp, -6.dbamp * [1, 1, 1, 1],
    \pan, Ptuple(
        Pwhite(-1.0, 1.0) ! 4,
    ),
    
    \pos, Pmod(
        {
            var rate, trig, decay;
            
            trig = \trig.tr(0);
            rate = \rate.kr(2);
            decay = \decay.kr(6);
            
            trig = Decay.kr(trig, decay);
            
            SinOsc.ar(trig * rate + [0, 1/24].resamp1(4)).range(
                "2:08".asSecs,
                "2:54".asSecs
            )
            + \offset.kr(250).lag(16)
            + LFTri.ar(\triRate.kr(1/428)).range(0, 8)
        },
        \trig, Prand([0, 0, 0, 0, 1], inf),
        \decay, Pxfade([
            2, 
            Prand([0.01, 0.3, 0.4, 6], inf)
        ], Pkey(\fade), \blend),
        \triRate, Pxfade(1 / [128, 400], Pkey(\fade), \blend),
        \offset, Pxfade([0, 290], Pkey(\fade), \blend).durStep(64),
        \rate, Pmod({
            |mult|
            mult * LFDNoise3.ar(1/5).exprange(1, 8)
        }, \mult, Pxfade([1/60, 1/2900], Pkey(\fade), \expBlend))
    ).expand,
    \posV, 0.0002,
    
    \trigRate, { ~detunedFreq.value * blend(2, 1, ~fade.value) },
    
    \density, Pxfade(
        [
            Pwhite(0.0, 1.0).lincurve(0, 1, 14.0, 62.0, -6),
            Ptuple(
                Pwhite(0.0, 1.0).lincurve(0, 1, 12, 160, 5) ! 4
            )
        ], 
        Pkey(\fade), \blend), 
    \octave, Pkey(\octave) + Pxfade([0, 2], Pkey(\fade), \random),
    
    \attack, Pxfade([
        0.5,
        Pxstep(Pwnrand([0.01, 0.06, 0.3], [20, 2, 1], inf), 2),
        0.03
    ], Pkey(\fade).lincurve(0, 1, 0, 2, 6), \random),
    \envCurve, Pxfade([0, -16, -20], Pkey(\fade) * 3, \blend),
    \ampEnv, {
        var attack;
        var sustain = ~sustain.value;
        var curve = ~envCurve.value;
        
        attack = blend(0.001, ~attack.value, ~fade.value);
        
        `(Env.perc(attack * sustain, (1 - attack) * sustain, curve:curve * [-1, 1]))
    },
    
    \env, 0.01,
    
    \trig, 0,
    
    \grainRate,  Pmod({
        (
            DC.ar([0, 24, 12, 0])
                + 4.collect {
                    Env.sine(0.5).ar(gate:Dust.ar(0.06))
                }.linlin(0, 1, 0, -1)
        ).midiratio
    }),
    // \grainRateV, 0.00001,
    
    \finish, {
        ~trigRate = ~trigRate.value;
    }
) <> Pdef(\notes));

////////////////////////////////////////////////////////////////////////////////////////////////////
// DELAY
////////////////////////////////////////////////////////////////////////////////////////////////////
Pdef(\delay, Pmono(
    \grainDelay2,
    \parentType, \grainDelay2,
    
    \fade, Pdefn(\fade),
    \dur, Prand([1/2, 3, 4, 5], inf),
    
    \finish, {
        ~in = ~in.value;
        ~grainRate = ~grainRate.value;
        ~trigRate = ~trigRate.value;
        ~grainRate = ~grainRate.value;
        ~delayRound = ~delayRound.value;
    },
    
    \delay, Pmod(
        {
            var flux = LFDNoise3.ar(1/8).exprange(
                \min.kr(1/164).lag(1),
                \max.kr(1/2).lag(1)
            );
            
            4.collect {
                DelayC.ar(flux, 1, LFDNoise3.kr(1/24).range(0, 1/18))
            }
        }, 
        \min, Pxfade([1/64, 1/16], Pkey(\fade), \blend),
        \max, Pxfade([1/8, 1/1], Pkey(\fade), \blend)
    ).expand,    
    
    \delayV, Pmod({
        1 / LFDNoise3.ar(1/24).lincurve(-1, 1, 200, 500, 0)
    }),
    \delayRound, { ~detunedFreq.value.reciprocal },
    \delayRoundLag, Pxfade([8, 0.5], Pkey(\fade), \expBlend),
    \delayRoundOffset, Pmod(
        {
            |speed|
            var roundOff = \roundOff.kr([1, 1, 1, 1]).lag(8);
            3.4 * roundOff * LFDNoise3.ar(speed).abs.lag(2 * [0.2, 1.0, 0.4, 0.0])
        }, 
        \speed, Pxfade([1/10, 1/4], Pkey(\fade), \blend),
        \roundOff, Pkey(\delayRound)
    ).expand,
    
    \trig, 0,
    
    \trigRate, Pxfade(60 * [12, 26], Pkey(\fade), \expBlend),
    \density, Pmod({
        LFTri.ar(LFDNoise3.ar(1/4).exprange(1/32, 1/2))
            .exprange(10, 90)
    }),
    \octave, Pkey(\octave) + Pxfade([0, 2], Pkey(\fade), \random),
    
    \grainRate, Pmod({
        4.collect {
            var trig = Dust.ar(0.12);
            (
                // Env.sine(4).ar(gate:trig)
                1
                * LFDNoise3.ar(1/4).range(0.0, 0.1)
            ).midiratio
        }
    }).expand,
    \grainRateV, Pxfade([
        0.004,
        Pwhite(0.0, 1.0).durStep(4).linexp(0, 1, 0.062, 0.06),
    ], Pkey(\fade).lincurve(0, 1, 0, 1, 4), \random),
    
    \feedAmp, Pxfade([-40.dbamp, -38.dbamp], Pkey(\fade), \blend),
    \feedDist, Pmod({
        |fade|
        blend(
            22 + Env.perc(2, 4, curve:\sine).ar(gate:Dust.ar(0.4)).linlin(0, 1, 0, 15),
            DC.ar(0.5)
        )
    }, \fade, Pkey(\fade), \blend),
    
    \filtLo, 20,
    \filtHi, Pxfade([
        Pexprand(3000, 19900).durStep(4),
        Pexprand(12000, 19900).durStep(4),
    ], Pkey(\fade), \blend),
    \filtLag, 4,
    
    \pan, Pmod({
        4.collect {
            0.8 * LFDNoise3.ar(1/12).range(-1, 1)
        }
    }).expand,
    \panV, 0.1,
    
    \amp, -10.dbamp,
    \dryAmp, -96.dbamp
) <> Pdef(\notes2));



////////////////////////////////////////////////////////////////////////////////////////////////////
// TECKDELAY
////////////////////////////////////////////////////////////////////////////////////////////////////
Pdef(\teckDelay, Pmono(
    \teckDelay,
    
    \inEnv, 0,
    
    \fade, Pdefn(\fade),
    
    \inAmp, -40.dbamp,
    \amp, -0.dbamp,
    \feed, -6.dbamp,
    \revAmp, -20.dbamp,
    \dryAmp, 10.dbamp,
    \kickAmp, -90.dbamp,
    \crushAmp, -20.dbamp,
    \wetAmp, Pxfade([-7.dbamp, -15.dbamp], Pkey(\fade), \blend)
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
        
        
            
                
                    
                        
                            
                                
                                    
                                        
                                            
                                                
                                                    
                                                        
                                                            
                                                                
                                                                    
                                                                        
                                                                            
                                                                                
                                                                                    
                                                                                        
                                                                                            
                                                                                                
                                                                                                    
                                                                                                        
                                                                                                            
                                                                                                                
                                                                                                                    
                                                                                                                        
                                                                                                                            
                                                                                                                                
                                                                                                                                    
                                                                                                                                        
                                                                                                                                            
                                                                                                                                                
                                                                                                                                                    
                                                                                                                                                        
                                                                                                                                                            
                                                                                                                                                                
                                                                                                                                                                    
                                                                                                                                                                        
                                                                                                                                                                            
                                                                                                                                                                                
                                                                                                                                                                                    
                                                                                                                                                                                        
                                                                                                                                                                                            
                                                                                                                                                                                                
                                                                                                                                                                                                    
                                                                                                                                                                                                        
                                                                                                                                                                                                            
                                                                                                                                                                                                                
                                                                                                                                                                                                                    
                                                                                                                                                                                                                        
                                                                                                                                                                                                                            
                                                                                                                                                                                                                                
                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                    
                                                                                                                                                                                                                                                                                                                                        
                                                                                                                                                                                                                                                                                                                                            
                                                                                                                                                                                                                                                                                                                                                