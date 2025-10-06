<script>
	import { base } from '$app/paths';
	import Hero from '$lib/components/Hero.svelte';
	import Footer from '$lib/components/Footer.svelte';
	import DebugPanel from '$lib/components/DebugPanel.svelte';
	import copy from '$lib/data/copy.json';
	import { fade } from 'svelte/transition';
	import { onMount } from 'svelte';
	import { isMobile, isTablet } from '$lib/stores/responsive.js';
	import GSAPScroller from '$lib/components/scroller/Scroller.svelte';
	import Scroller from '$lib/components/scrolly/_Scroller.svelte';
	import Background from '$lib/components/scrolly/Background.svelte';
	import Slide from '$lib/components/scrolly/Slide.svelte';
	import TextFooter from '$lib/components/scrolly/TextFooter.svelte';
	import CTA from '$lib/components/CTA.svelte';
	import Dashboard from '$lib/components/scrolly/dashboard/Dashboard.svelte';
	import Quiz from '$lib/components/quiz/Quiz.svelte';
	const { meta, content } = copy;

	let count2 = $state(0);
	let index2 = $state(0);
	let offset2 = $state(0);
	let progress2 = $state(0);
	let top2 = 0;
	let threshold2 = 0.25;
	let bottom2 = 1;

	let interactiveMode = $state(false);

	let showQuiz = $state(false);

	// Derived variables for each Scrolly component

	const activeSlide2 = $derived(content.scrolly.slidesFixed[index2]);
</script>

<svelte:head>
	<title>{meta.title}</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
	<meta
		name="description"
		content={meta.description || 'Interactive civic responsibility exploration'}
	/>
</svelte:head>

<div class="header-bg"></div>

<Quiz />

<style lang="scss">
	@import '$lib/styles/mixins.scss';

	.header-bg {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: var(--header-height, 80px);
		background-color: var(--color-theme-blue-light);
		z-index: 10;

	}
	// Accessibility utilities
	.visually-hidden {
		position: absolute !important;
		width: 1px !important;
		height: 1px !important;
		padding: 0 !important;
		margin: -1px !important;
		overflow: hidden !important;
		clip: rect(0, 0, 0, 0) !important;
		white-space: nowrap !important;
		border: 0 !important;
	}
</style>
