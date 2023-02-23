---
title: "FLOW_DSL_API"
date: 2023-02-10T17:36:36+08:00
draft: true
---

##
a->{
    [b->c],
    [d->e->f],
    [g->{
        [h->i->{
            [j],
            [k]
        }],
        [l->m]
    }->n]
}->z

a->b->{
    [d->e->f],
    [c->{
        [g->{
            [h->i],
            [j]
        }->k],
        [l->m]
    }]
}->z