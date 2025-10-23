import"../chunks/NZTpNUN0.js";import{J as S,R as W,B as T,T as J,U as K,C as n,N as C,am as re,A as d,K as x,s as E,ai as L,O as y,j as o,ak as P,P as $,F as z,Q as oe,an as U,ah as ie,ao as ne,ap as le}from"../chunks/vgzABbBy.js";import{s as ce,c as ue}from"../chunks/Uknf5098.js";import{I as V,s as de,a as N,i as ve,b as pe}from"../chunks/DoHuD1ru.js";import{s as Y,r as G,p as he,i as R,a as X,b as j}from"../chunks/8yPeVS-i.js";import{b as q}from"../chunks/DcMYCjHg.js";import{b as me}from"../chunks/D_6Pv4dq.js";import{s as fe,b as be}from"../chunks/CxpF7Z9E.js";import{L as ge,H as _e}from"../chunks/CGgAzUea.js";const ye=!0,$e=ye,we=!0,Je=Object.freeze(Object.defineProperty({__proto__:null,prerender:we},Symbol.toStringTag,{value:"Module"})),qe=()=>{const s=fe;return{page:{subscribe:s.page.subscribe},navigating:{subscribe:s.navigating.subscribe},updated:s.updated}},Z={subscribe(s){return qe().page.subscribe(s)}};function xe(s,e){S(e,!0);/**
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
 */let p=G(e,["$$slots","$$events","$$legacy"]);const b=[["path",{d:"M3 3v16a2 2 0 0 0 2 2h16"}],["path",{d:"M7 16h8"}],["path",{d:"M7 11h12"}],["path",{d:"M7 6h3"}]];V(s,Y({name:"chart-bar"},()=>p,{get iconNode(){return b},children:(i,u)=>{var l=W(),h=T(l);J(h,()=>e.children??K),n(i,l)},$$slots:{default:!0}})),C()}function ze(s,e){S(e,!0);/**
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
 */let p=G(e,["$$slots","$$events","$$legacy"]);const b=[["path",{d:"M11.5 15H7a4 4 0 0 0-4 4v2"}],["path",{d:"M21.378 16.626a1 1 0 0 0-3.004-3.004l-4.01 4.012a2 2 0 0 0-.506.854l-.837 2.87a.5.5 0 0 0 .62.62l2.87-.837a2 2 0 0 0 .854-.506z"}],["circle",{cx:"10",cy:"7",r:"4"}]];V(s,Y({name:"user-pen"},()=>p,{get iconNode(){return b},children:(i,u)=>{var l=W(),h=T(l);J(h,()=>e.children??K),n(i,l)},$$slots:{default:!0}})),C()}function He(s,e){o(e)&&$e?window.history.back():window.location.href=q+"/"}var ke=d('<a class="nav-button back-button svelte-qu7iyo"><!> </a>'),Me=d("<span>Dashboard</span>"),Pe=d('<!> <span class="full-text svelte-qu7iyo">View the data dashboard</span> <span class="short-text svelte-qu7iyo">Explore data</span>',1),Re=d('<a class="nav-button dashboard-button svelte-qu7iyo"><!></a>'),Te=d("<span>Quiz</span>"),Be=d(`<!> <span class="full-text svelte-qu7iyo">What's your Civic Profile? Take our interactive quiz.</span> <span class="short-text svelte-qu7iyo">Take quiz</span>`,1),Ee=d('<a class="nav-button quiz-button svelte-qu7iyo"><!></a>'),Ne=d('<header aria-label="Site navigation"><div class="header-left svelte-qu7iyo"><!></div> <div class="header-right svelte-qu7iyo"><!> <!> <!></div></header>');function Se(s,e){S(e,!0);const[p,b]=X(),i=()=>j(Z,"$page",p),u=()=>j(ve,"$isMobile",p);let l=he(e,"headerHeight",15),h=P(()=>i().url.pathname.includes("/dashboard")||i().url.pathname.includes("/quiz")),m=L(""),g=P(()=>i().url.pathname.includes("/dashboard")||i().url.pathname.includes("/quiz"));be(t=>{t.from&&E(m,t.from.url.pathname,!0)});let H=P(()=>o(g)?o(m)==="/"||o(m)===q||o(m)===q+"/":!1),B=P(()=>u()?"":o(H)?"Return to main page":"Main page");var _=Ne();let c;var f=y(_),k=y(f);const A=P(()=>u()?"medium":"large");ge(k,{get size(){return o(A)}}),$(f);var F=z(f,2),D=y(F);{var ee=t=>{var a=ke();a.__click=[He,H];var w=y(a);_e(w,{size:20});var M=z(w);$(a),x(()=>{N(a,"href",q+"/"),oe(M,` ${o(B)??""}`)}),n(t,a)};R(D,t=>{o(g)&&t(ee)})}var Q=z(D,2);{var te=t=>{var a=Re(),w=y(a);{var M=r=>{var v=Me();n(r,v)},O=r=>{var v=Pe(),I=T(v);xe(I,{size:16}),U(4),n(r,v)};R(w,r=>{u()?r(M):r(O,!1)})}$(a),x(()=>N(a,"href",q+"/dashboard")),n(t,a)};R(Q,t=>{i().url.pathname.includes("/dashboard")||t(te)})}var ae=z(Q,2);{var se=t=>{var a=Ee(),w=y(a);{var M=r=>{var v=Te();n(r,v)},O=r=>{var v=Be(),I=T(v);ze(I,{size:16}),U(4),n(r,v)};R(w,r=>{u()?r(M):r(O,!1)})}$(a),x(()=>N(a,"href",q+"/quiz")),n(t,a)};R(ae,t=>{i().url.pathname.includes("/quiz")||t(se)})}$(F),$(_),x(t=>c=de(_,1,"main-header svelte-qu7iyo",null,c,t),[()=>({bg:o(h)})]),me(_,"clientHeight",l),n(s,_),C(),b()}re(["click"]);var Ce=d('<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover"/> <meta name="description"/>',1),Oe=d('<main role="main" aria-label="Civic Responsibility Interactive Experience"><!> <!></main>');function Ke(s,e){S(e,!0);const[p,b]=X(),i=()=>j(Z,"$page",p);let u=L(0),l=L(!1);const{meta:h}=ue;function m(){const c=window.pageYOffset||document.documentElement.scrollTop,f=document.documentElement.scrollHeight,k=window.innerHeight;c+k>=f-10&&!o(l)&&setTimeout(()=>{E(l,!0)},500)}ie(()=>{if(i().url.pathname==="/")return m(),window.addEventListener("scroll",m),()=>{window.removeEventListener("scroll",m)};E(l,!0)});var g=Oe();ne(c=>{var f=Ce(),k=z(T(f),2);x(()=>{le.title=h.title,N(k,"content",h.description||"Interactive civic responsibility exploration")}),n(c,f)});let H;var B=y(g);Se(B,{get headerHeight(){return o(u)},set headerHeight(c){E(u,c,!0)}});var _=z(B,2);ce(_,e,"default",{}),$(g),x(c=>H=pe(g,"",H,c),[()=>({"--header-height":`${o(u)??""}px`})]),n(s,g),C(),b()}export{Ke as component,Je as universal};
