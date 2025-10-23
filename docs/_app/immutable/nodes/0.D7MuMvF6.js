import"../chunks/NZTpNUN0.js";import{J as S,R as F,B as w,T as L,U as Q,C as n,N as T,am as te,A as d,K as y,s as U,ai as W,O as b,j as i,ak as k,P as f,F as $,Q as se,an as E,ao as re,ap as oe}from"../chunks/vgzABbBy.js";import{s as ie,c as ne}from"../chunks/Uknf5098.js";import{I as A,s as le,a as P,i as ce,b as ue}from"../chunks/DoHuD1ru.js";import{b as g}from"../chunks/D6z9ekA6.js";import{s as J,r as K,p as de,i as M,a as ve,b as D}from"../chunks/8yPeVS-i.js";import{b as pe}from"../chunks/D_6Pv4dq.js";import{s as he,b as me}from"../chunks/CRiA33BI.js";import{L as be,H as fe}from"../chunks/CRcxD3Q1.js";const _e=!0,ge=_e,ye=!0,Ae=Object.freeze(Object.defineProperty({__proto__:null,prerender:ye},Symbol.toStringTag,{value:"Module"})),$e=()=>{const r=he;return{page:{subscribe:r.page.subscribe},navigating:{subscribe:r.navigating.subscribe},updated:r.updated}},qe={subscribe(r){return $e().page.subscribe(r)}};function xe(r,a){S(a,!0);/**
 * @license @lucide/svelte v0.525.0 - ISC
 *
 * ISC License
 *
 * Copyright (c) for portions of Lucide are held by Cole Bemis 2013-2022 as part of Feather (MIT). All other copyright (c) for Lucide are held by Lucide Contributors 2022.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */let l=K(a,["$$slots","$$events","$$legacy"]);const h=[["path",{d:"M3 3v16a2 2 0 0 0 2 2h16"}],["path",{d:"M7 16h8"}],["path",{d:"M7 11h12"}],["path",{d:"M7 6h3"}]];A(r,J({name:"chart-bar"},()=>l,{get iconNode(){return h},children:(t,v)=>{var c=F(),m=w(c);L(m,()=>a.children??Q),n(t,c)},$$slots:{default:!0}})),T()}function ze(r,a){S(a,!0);/**
 * @license @lucide/svelte v0.525.0 - ISC
 *
 * ISC License
 *
 * Copyright (c) for portions of Lucide are held by Cole Bemis 2013-2022 as part of Feather (MIT). All other copyright (c) for Lucide are held by Lucide Contributors 2022.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */let l=K(a,["$$slots","$$events","$$legacy"]);const h=[["path",{d:"M11.5 15H7a4 4 0 0 0-4 4v2"}],["path",{d:"M21.378 16.626a1 1 0 0 0-3.004-3.004l-4.01 4.012a2 2 0 0 0-.506.854l-.837 2.87a.5.5 0 0 0 .62.62l2.87-.837a2 2 0 0 0 .854-.506z"}],["circle",{cx:"10",cy:"7",r:"4"}]];A(r,J({name:"user-pen"},()=>l,{get iconNode(){return h},children:(t,v)=>{var c=F(),m=w(c);L(m,()=>a.children??Q),n(t,c)},$$slots:{default:!0}})),T()}function ke(r,a){i(a)&&ge?window.history.back():window.location.href=g+"/"}var Me=d('<a class="nav-button back-button svelte-qu7iyo"><!> </a>'),we=d("<span>Dashboard</span>"),He=d('<!> <span class="full-text svelte-qu7iyo">View the data dashboard</span> <span class="short-text svelte-qu7iyo">Explore data</span>',1),Pe=d('<a class="nav-button dashboard-button svelte-qu7iyo"><!></a>'),Re=d("<span>Quiz</span>"),Ne=d(`<!> <span class="full-text svelte-qu7iyo">What's your Civic Profile? Take our interactive quiz.</span> <span class="short-text svelte-qu7iyo">Take quiz</span>`,1),Ce=d('<a class="nav-button quiz-button svelte-qu7iyo"><!></a>'),Se=d('<header aria-label="Site navigation"><div class="header-left svelte-qu7iyo"><!></div> <div class="header-right svelte-qu7iyo"><!> <!> <!></div></header>');function Te(r,a){S(a,!0);const[l,h]=ve(),t=()=>D(qe,"$page",l),v=()=>D(ce,"$isMobile",l);let c=de(a,"headerHeight",15),m=k(()=>t().url.pathname.includes("/dashboard")||t().url.pathname.includes("/quiz")),u=W(""),q=k(()=>t().url.pathname.includes("/dashboard")||t().url.pathname.includes("/quiz"));me(e=>{e.from&&U(u,e.from.url.pathname,!0)});let H=k(()=>i(q)?i(u)==="/"||i(u)===g||i(u)===g+"/":!1),V=k(()=>v()?"":i(H)?"Return to main page":"Main page");var x=Se();let B;var R=b(x),G=b(R);const X=k(()=>v()?"medium":"large");be(G,{get size(){return i(X)}}),f(R);var I=$(R,2),O=b(I);{var Y=e=>{var s=Me();s.__click=[ke,H];var _=b(s);fe(_,{size:20});var z=$(_);f(s),y(()=>{P(s,"href",g+"/"),se(z,` ${i(V)??""}`)}),n(e,s)};M(O,e=>{i(q)&&e(Y)})}var j=$(O,2);{var Z=e=>{var s=Pe(),_=b(s);{var z=o=>{var p=we();n(o,p)},N=o=>{var p=He(),C=w(p);xe(C,{size:16}),E(4),n(o,p)};M(_,o=>{v()?o(z):o(N,!1)})}f(s),y(()=>P(s,"href",g+"/dashboard")),n(e,s)};M(j,e=>{t().url.pathname.includes("/dashboard")||e(Z)})}var ee=$(j,2);{var ae=e=>{var s=Ce(),_=b(s);{var z=o=>{var p=Re();n(o,p)},N=o=>{var p=Ne(),C=w(p);ze(C,{size:16}),E(4),n(o,p)};M(_,o=>{v()?o(z):o(N,!1)})}f(s),y(()=>P(s,"href",g+"/quiz")),n(e,s)};M(ee,e=>{t().url.pathname.includes("/quiz")||e(ae)})}f(I),f(x),y(e=>B=le(x,1,"main-header svelte-qu7iyo",null,B,e),[()=>({bg:i(m)})]),pe(x,"clientHeight",c),n(r,x),T(),h()}te(["click"]);var Be=d('<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover"/> <meta name="description"/>',1),Ie=d('<main role="main" aria-label="Civic Responsibility Interactive Experience"><!> <!></main>');function Je(r,a){let l=W(0);const{meta:h}=ne;var t=Ie();re(u=>{var q=Be(),H=$(w(q),2);y(()=>{oe.title=h.title,P(H,"content",h.description||"Interactive civic responsibility exploration")}),n(u,q)});let v;var c=b(t);Te(c,{get headerHeight(){return i(l)},set headerHeight(u){U(l,u,!0)}});var m=$(c,2);ie(m,a,"default",{}),f(t),y(u=>v=ue(t,"",v,u),[()=>({"--header-height":`${i(l)??""}px`})]),n(r,t)}export{Je as component,Ae as universal};
