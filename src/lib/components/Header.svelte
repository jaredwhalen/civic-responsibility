<script>
	import { base } from '$app/paths';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	import { afterNavigate } from '$app/navigation';
	import { Home, ChartBar, UserPen } from '@lucide/svelte';
	import Lockup from './Lockup.svelte';
	import { isMobile } from '$lib/stores/responsive.js';

	let { headerHeight = $bindable(), mode = 'main' } = $props();

	let bg = $derived(
		$page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz')
	);

	// Derive button text based on navigation state
	let backButtonText = $derived($isMobile ? '' : 'Main page');

	function handleBackClick() {
		if (mode === 'route') {
			// Check if we came from Explore buttons
			const cameFromExplore = $page.url.search.includes('fromExplore=true');

			if (cameFromExplore) {
				// Go to main page with trigger for +page.svelte
				window.location.href = base + '/?fromExplore=true';
			} else {
				// Simple scroll to top on main page
				window.location.href = base + '/';
			}
		} else {
			window.location.href = base + '/';
		}
	}

	// When on main page and returning from a route (via fromExplore param)
	let fromExplore = $derived(mode === 'main' && $page.url.search.includes('fromExplore=true'));

	function urlClean() {
		const url = new URL(window.location.href);
		url.searchParams.delete('fromExplore');
		window.history.replaceState({}, '', url.pathname + url.search + url.hash);
	}

	// Clean up URL params immediately after navigation
	afterNavigate(() => {
		if ($page.url.search.includes('fromExplore=true')) {
			urlClean();
		}
	});

	onMount(() => {
		if (fromExplore) {
			urlClean();
		}
	});
</script>

<header
	class="main-header {mode}"
	aria-label="Site navigation"
	bind:clientHeight={headerHeight}
	class:bg
>
	<div class="header-left">
		<Lockup interactive={mode === 'main'} size={$isMobile ? 'medium' : 'large'} />
	</div>

	<div class="header-right">
		{#if mode === 'route'}
			<button class="nav-button back-button" onclick={handleBackClick}>
				<Home size={20} />
				{backButtonText}
			</button>

			{#if !$page.url.pathname.includes('/dashboard')}
				{@const param = $page.url.search.includes('fromExplore=true') ? '?fromExplore=true' : ''}
				<a href={base + '/dashboard' + param} class="nav-button dashboard-button">
					{#if $isMobile}
						<span>Dashboard</span>
					{:else}
						<ChartBar size={16} />
						<span class="full-text">View the data dashboard</span>
						<span class="short-text">Explore data</span>
					{/if}
				</a>
			{/if}
			{#if !$page.url.pathname.includes('/quiz')}
				{@const param = $page.url.search.includes('fromExplore=true') ? '?fromExplore=true' : ''}
				<a href={base + '/quiz' + param} class="nav-button quiz-button">
					{#if $isMobile}
						<span>Quiz</span>
					{:else}
						<UserPen size={16} />
						<span class="full-text">What's your Civic Profile? Take our interactive quiz.</span>
						<span class="short-text">Take quiz</span>
					{/if}
				</a>
			{/if}
		{:else}
			{#if !$page.url.pathname.includes('/dashboard')}
				<a href={base + '/dashboard'} target="_blank" class="nav-button dashboard-button">
					{#if $isMobile}
						<span>Dashboard</span>
					{:else}
						<ChartBar size={16} />
						<span class="full-text">View the data dashboard</span>
						<span class="short-text">Explore data</span>
					{/if}
				</a>
			{/if}
			{#if !$page.url.pathname.includes('/quiz')}
				<a href={base + '/quiz'} target="_blank" class="nav-button quiz-button">
					{#if $isMobile}
						<span>Quiz</span>
					{:else}
						<UserPen size={16} />
						<span class="full-text">What's your Civic Profile? Take our interactive quiz.</span>
						<span class="short-text">Take quiz</span>
					{/if}
				</a>
			{/if}
		{/if}
	</div>
</header>

<style lang="scss">
	@import '../styles/mixins.scss';

	.main-header {
		position: absolute;
		top: 0;
		left: 0;
		right: 0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: $spacing-sm $spacing-lg;
		z-index: 1000;
		pointer-events: none;
		height: 80px;

		&.route {
			flex-direction: row-reverse;
		}

		&.bg {
			background: var(--color-theme-blue);
		}

		// Mobile responsive adjustments
		@include mq('mobile', 'max') {
			height: 60px;
			padding: $spacing-xs $spacing-md;
		}

		@include mq('small-mobile', 'max') {
			height: 50px;
			padding: $spacing-xs $spacing-sm;
		}

		.header-left {
			pointer-events: auto;
			flex-shrink: 0; // Prevent Lockup from squishing
		}

		.header-right {
			pointer-events: auto;
			display: flex;
			gap: $spacing-md;
			align-items: center;
			flex-shrink: 1;
			min-width: 0; // Allow flex items to shrink below content size

			// Hide buttons on smaller screens
			@include mq('mobile', 'max') {
				gap: $spacing-sm;
			}

			.nav-button {
				// Consistent base styling for all nav buttons
				padding: 0.5rem 1rem;
				border-radius: 6px;
				cursor: pointer;
				font-size: 0.9rem;
				font-weight: 600;
				text-decoration: none;
				transition: all 0.3s ease;
				white-space: nowrap;
				display: flex;
				align-items: center;
				justify-content: center;
				gap: 0.5rem;
				min-height: 2.5rem; // Ensure consistent height
				box-sizing: border-box;
				border: none;
				height: 35px;

				// Mobile responsive adjustments
				@include mq('mobile', 'max') {
					padding: 0.4rem 0.8rem;
					font-size: 0.8rem;
					min-height: 2rem;
				}

				// Show full text by default, hide short text
				.short-text {
					display: none;
				}

				// Below 1000px, show short text and hide full text
				@media (max-width: 1000px) {
					.full-text {
						display: none;
					}
					.short-text {
						display: inline;
					}
				}

				&:hover {
					transform: translateY(-2px);
					box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
				}

				// Default styling for dashboard and quiz buttons
				&.dashboard-button,
				&.quiz-button {
					color: var(--color-theme-light);
					@include glass-effect(rgba(255, 255, 255, 0.15), rgba(255, 255, 255, 0.3));
				}

				// Special styling for back button
				&.back-button {
					color: var(--color-theme-light);
					background: rgba(255, 255, 255, 0.1);
					border: 1px solid rgba(255, 255, 255, 0.2);

					&:hover {
						background: rgba(255, 255, 255, 0.15);
						border-color: rgba(255, 255, 255, 0.3);
					}
				}
			}
		}
	}
</style>
