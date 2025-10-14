<script>
	import { base } from '$app/paths';
	import { page } from '$app/stores';
	import { browser } from '$app/environment';
	import { beforeNavigate } from '$app/navigation';
	import { Home, ChartBar, UserPen } from '@lucide/svelte';
	import Lockup from './Lockup.svelte';
	import { isMobile } from '$lib/stores/responsive.js';

	let { headerHeight = $bindable() } = $props();

	let bg = $derived(
		$page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz')
	);
	let previousPath = $state('');
	let isRoutePage = $derived(
		$page.url.pathname.includes('/dashboard') || $page.url.pathname.includes('/quiz')
	);

	// Track the previous path to determine navigation behavior
	beforeNavigate((navigation) => {
		if (navigation.from) {
			previousPath = navigation.from.url.pathname;
		}
	});

	// Determine if we came directly from root
	let cameDirectlyFromRoot = $derived.by(() => {
		if (!isRoutePage) return false;
		// Check if previous path was root (/ or /base)
		return previousPath === '/' || previousPath === base || previousPath === base + '/';
	});

	// Derive button text based on navigation state
	let backButtonText = $derived($isMobile ? '' : cameDirectlyFromRoot ? 'Go back home' : 'Home');

	function handleBackClick() {
		if (cameDirectlyFromRoot && browser) {
			// Use browser back to maintain scroll position when coming directly from root
			window.history.back();
		} else {
			// Navigate to root page for all other cases (came from another route, external, etc)
			window.location.href = base + '/';
		}
	}
</script>

<header class="main-header" aria-label="Site navigation" bind:clientHeight={headerHeight} class:bg>
	<div class="header-left">
		<Lockup size={$isMobile ? 'medium' : 'large'} />
	</div>

	<div class="header-right">
		{#if isRoutePage}
			<a href={base + '/'} class="nav-button back-button" onclick={handleBackClick}>
				<Home size={20} />
				{backButtonText}
			</a>
		{/if}
		{#if !$page.url.pathname.includes('/dashboard')}
			<a href={base + '/dashboard'} class="nav-button dashboard-button">
				{#if $isMobile}
					<span>Data</span>
				{:else}
					<ChartBar size={16} />
					<span class="full-text">View the data dashboard</span>
					<span class="short-text">Explore data</span>
				{/if}
			</a>
		{/if}
		{#if !$page.url.pathname.includes('/quiz')}
			<a href={base + '/quiz'} class="nav-button quiz-button">
				{#if $isMobile}
					<span>Quiz</span>
				{:else}
					<UserPen size={16} />
					<span class="full-text">What's your Civic Profile? Take our interactive quiz.</span>
					<span class="short-text">Take quiz</span>
				{/if}
			</a>
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
		z-index: 100000;
		pointer-events: none;
		height: 80px;
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
