<script>
	import { fade, fly } from 'svelte/transition';
	import { onMount } from 'svelte';
	import smoothScroll from '$lib/helpers/smoothScroll.js';

	let {
		activeView = $bindable(),
		selectedStateView = $bindable(),
		selectedStateViewOption = $bindable(),
		searchOptions,
		interactiveMode = $bindable()
	} = $props();
	let selectedOption = $state(null);

	let isDropdownOpen = $state(false);
	let buttonRefs = $state({});
	let isMounted = $state(false);
	let isDismounting = $state(false);
	let containerHeight = $state(0);

	// Derived resultsOptions array based on selectedStateView
	let resultsOptions = $derived(
		selectedStateView === 'chart'
			? Array.from(searchOptions.states).map((state) => ({ label: state, value: state }))
			: Array.from(searchOptions.duties).map((duty) => ({ label: duty, value: duty }))
	);

	// Update selectedStateViewOption when resultsOptions change
	$effect(() => {
		if (
			resultsOptions.length > 0 &&
			!resultsOptions.find((opt) => opt.value === selectedStateViewOption)
		) {
			selectedStateViewOption = resultsOptions[0].value;
		}
	});

	const options = [
		{
			label: 'Gender',
			value: 'gender'
		},
		{
			label: 'Generation',
			value: 'generation'
		},
		{
			label: 'Race/Ethnicity',
			value: 'race'
		},
		{
			label: 'Political Identification',
			value: 'pid'
		},
		{
			label: 'State',
			value: 'state'
		}
	];

	const stateViewOptions = [
		{
			label: 'Chart',
			value: 'chart'
		},
		{
			label: 'Map',
			value: 'map'
		}
	];

	$effect(() => {
		if (activeView == 'mean') {
			selectedOption = null;
			selectedStateViewOption = resultsOptions[0]?.value;
			isDropdownOpen = false;

			Object.values(buttonRefs).forEach((ref) => {
				if (ref && ref === document.activeElement) {
					ref.blur();
				}
			});
		}
	});

	$effect(() => {
		// Reset selected state when view type changes
		selectedStateViewOption = resultsOptions[0]?.value;
		isDropdownOpen = false;
	});

	onMount(() => {
		// Get the actual height of the content
		const container = document.querySelector('.controls-content');
		if (container) {
			containerHeight = container.scrollHeight;
		}
		
		// Trigger height animation after a brief delay to ensure DOM is ready
		setTimeout(() => {
			isMounted = true;
		}, 50);
	});

	// Function to handle dismounting with animation
	function handleDismount() {
		isDismounting = true;
		// Wait for animation to complete before actually changing interactiveMode
		// setTimeout(() => {
			interactiveMode = false;
		// }, 0); // Match the CSS transition duration
	}

	function handleSelect(value) {
		if (value == selectedOption) {
			selectedOption = null;
			activeView = 'mean';
			return;
		}

		selectedOption = value;
		if (value == null) {
			activeView = 'mean';
		} else {
			activeView = value;
		}
	}

	function handleStateSelect(value) {
		selectedStateViewOption = value;
		isDropdownOpen = false;
	}

	function toggleDropdown() {
		isDropdownOpen = !isDropdownOpen;
	}

	// Close dropdown when clicking outside
	function handleClickOutside(event) {
		if (!event.target.closest('.dropdown-container')) {
			isDropdownOpen = false;
		}
	}
</script>

<!-- <svelte:window on:click={handleClickOutside} /> -->
<div 
	class="controls-container {isMounted ? 'mounted' : ''} {isDismounting ? 'dismounting' : ''}" 
	style="height: {isMounted && !isDismounting ? containerHeight + 'px' : '0px'}"
>
	<div class="controls-content">
		<button onclick={handleDismount} data-button="back">← Exit dashboard</button>
		<div class="dashboard-controls">
			<div class="dashboard-controls-inner">
				<div class="dashboard-controls-inner-title">
					<h3>View data by</h3>
				</div>

				<div class="dashboard-controls-inner-options">
					{#each options as option}
						<button
							bind:this={buttonRefs[option.value]}
							class="dashboard-controls-inner-option {selectedOption === option.value
								? 'selected'
								: ''}"
							onclick={() => handleSelect(option.value)}
						>
							{option.label}
						</button>
					{/each}
				</div>
			</div>

			{#if activeView == 'state'}
				<div class="dashboard-controls-inner">
					<div class="dashboard-controls-inner-title">
						<h3>View type</h3>
					</div>

					<div class="dashboard-controls-inner-options">
						{#each stateViewOptions as option}
							<button
								onclick={() => (selectedStateView = option.value)}
								class="dashboard-controls-inner-option {selectedStateView === option.value
									? 'selected'
									: ''}">{option.label}</button
							>
						{/each}
					</div>
				</div>

				<div class="dashboard-controls-inner">
					<div class="dashboard-controls-inner-title">
						<h3>View results for</h3>
					</div>

					<div class="dropdown-container">
						<button class="dropdown-button" onclick={toggleDropdown} aria-expanded={isDropdownOpen}>
							<span class="dropdown-arrow">▼</span>
							<span class="dropdown-text">
								{selectedStateViewOption ||
									(selectedStateView === 'chart' ? 'Select a state' : 'Select a duty')}
							</span>
						</button>

						{#if isDropdownOpen}
							<div class="dropdown-menu" transition:fade={{ duration: 200 }}>
								{#each resultsOptions as option}
									<button
										class="dropdown-item {selectedStateViewOption === option.value ? 'selected' : ''}"
										onclick={() => handleStateSelect(option.value)}
									>
										{option.label}
									</button>
								{/each}
							</div>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	</div>
</div>

<style lang="scss">
	.dashboard-controls {
		// position: absolute;
		// top: 0;
		// left: 0;
		// right: 0;
		// width: 100%;
		// max-width: 1400px;
		// margin: 1rem auto;

		display: flex;
		flex-wrap: wrap;
		gap: 0rem;

		.dashboard-controls-inner {
			margin: 1rem;
			width: fit-content;

			.dashboard-controls-inner-title {
				h3 {
					font-size: 1rem;
					font-weight: 600;
					margin: 0px 0px 5px;
				}
			}

			.dashboard-controls-inner-options {
				border-radius: 0.25rem;
				box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.1);
				background-color: #fff;
				padding: 0.5rem;

				display: flex;
				justify-content: center;
				align-items: center;
				gap: 0.25rem;

				.dashboard-controls-inner-option {
					padding: 0.5rem 1rem;
					border: none;
					border-radius: 0.25rem;
					background: transparent;
					color: #666;
					font-size: 14px;
					font-weight: 500;
					cursor: pointer;
					transition: all 0.2s ease;
					font-family: sans-serif;

					&.selected {
						background-color: $color-beacon-yellow;
						color: #000;
						// font-weight: 600;
					}

					&:hover:not(.selected) {
						background-color: #f5f5f5;
						color: #333;
					}
				}
			}
		}

		.dropdown-container {
			position: relative;
			width: fit-content;

			.dropdown-button {
				width: 100%;
				padding: 1rem 1rem;
				border: none;
				border-radius: 0.25rem;
				background-color: #fff;
				color: #666;
				font-size: 14px;
				font-weight: 500;
				cursor: pointer;
				transition: all 0.2s ease;
				font-family: sans-serif;
				box-shadow: 0 0 10px 0 rgba(0, 0, 0, 0.1);
				display: flex;
				align-items: center;
				justify-content: space-between;
				text-align: left;

				&:hover {
					background-color: #f8f8f8;
				}

				.dropdown-arrow {
					color: #999;
					font-size: 10px;
					transition: transform 0.2s ease;
					margin-right: 0.5rem;
				}

				&[aria-expanded='true'] .dropdown-arrow {
					// transform: rotate(180deg);
				}

				.dropdown-text {
					flex: 1;
					margin-right: 0.5rem;
				}
			}

			.dropdown-menu {
				position: absolute;
				top: 100%;
				left: 0;
				right: 0;
				background-color: #fff;
				border-radius: 0.5rem;
				box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.15);
				margin-top: 0.25rem;
				max-height: 200px;
				overflow-y: auto;
				z-index: 1000;

				.dropdown-item {
					width: 100%;
					padding: 0.75rem 1rem;
					border: none;
					background: transparent;
					color: #666;
					font-size: 14px;
					font-weight: 500;
					cursor: pointer;
					transition: all 0.2s ease;
					font-family: sans-serif;
					text-align: left;
					border-radius: 0;

					&:first-child {
						border-top-left-radius: 0.5rem;
						border-top-right-radius: 0.5rem;
					}

					&:last-child {
						border-bottom-left-radius: 0.5rem;
						border-bottom-right-radius: 0.5rem;
					}

					&:hover {
						background-color: #f5f5f5;
						color: #333;
					}

					&.selected {
						background-color: $color-beacon-yellow;
						color: #000;
					}
				}
			}
		}
	}

	.controls-container {
		overflow: hidden;
		transition: height 0.6s cubic-bezier(0.4, 0, 0.2, 1), 
		            transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
		transform: translateY(-100px);
		opacity: 0;
		
		&.mounted {
			transform: translateY(0);
			opacity: 1;
		}
		
		&.dismounting {
			transform: translateY(-100px);
			opacity: 0;
		}
	}

	.controls-content {
		// Content wrapper to measure height
	}

	button[data-button="back"] {
		background: none;
		border: none;
		color: #666;
		font-size: 14px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.2s ease;
	}
</style>
