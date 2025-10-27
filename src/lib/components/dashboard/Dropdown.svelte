<script>
	import { fade } from 'svelte/transition';
	import stateAbbreviations from '$lib/data/stateAbbreviations.json';

	// ===== PROPS =====
	let {
		options = [],
		selectedValues = $bindable([]),
		selectedValue = $bindable(''),
		viewMode = 'map', // 'chart' or 'map'
		onSelect = () => {},
		isOpen = $bindable(false),
		maxSelections = 3
	} = $props();

	// ===== LOCAL STATE =====
	let isDropdownOpen = $state(false);

	// ===== COMPUTED VALUES =====
	$effect(() => {
		isDropdownOpen = isOpen;
	});

	// ===== EVENT HANDLERS =====
	function toggleDropdown() {
		isDropdownOpen = !isDropdownOpen;
		if (isOpen !== isDropdownOpen) {
			isOpen = isDropdownOpen;
		}
	}

	function handleSelect(value) {
		onSelect(value);
		isDropdownOpen = false;
		isOpen = false;
	}

	function removeState(stateToRemove, event) {
		event?.stopPropagation();
		onSelect(stateToRemove); // Toggle off by selecting again
	}

	function isSelected(value) {
		if (viewMode === 'chart') {
			return selectedValues.includes(value);
		}
		return selectedValue === value;
	}

	function isDisabled(value) {
		return (
			viewMode === 'chart' && selectedValues.length >= maxSelections && !selectedValues.includes(value)
		);
	}

	function getDisplayText() {
		if (viewMode === 'chart') {
			if (selectedValues.length === 0) {
				return 'Select up to 3 states';
			} else if (selectedValues.length === 1) {
				return selectedValues[0];
			} else {
				return `${selectedValues.length} states selected`;
			}
		} else {
			return selectedValue || 'Select a duty';
		}
	}

	function getStateAbbreviation(stateName) {
		return stateAbbreviations[stateName] || stateName;
	}

	// Expose method to close dropdown from parent
	export function close() {
		isDropdownOpen = false;
		isOpen = false;
	}
</script>

<div class="dropdown-container">
	<button class="dropdown-button" onclick={toggleDropdown} aria-expanded={isDropdownOpen}>
		<span class="dropdown-arrow" class:is-open={isDropdownOpen}>▼</span>
		<span class="dropdown-text">
			{#if viewMode === 'chart'}
				<!-- State pills for chart view -->
						{#if selectedValues.length > 0}
							<div class="state-pills">
								{#each selectedValues as state}
									<div
										class="state-pill"
										onclick={(e) => removeState(state, e)}
										onkeydown={(e) => {
											if (e.key === 'Enter' || e.key === ' ') {
												e.preventDefault();
												removeState(state, e);
											}
										}}
										role="button"
										tabindex="0"
										aria-label="Remove {state}"
									>
										<span class="state-name">{getStateAbbreviation(state)}</span>
										<span class="remove-icon" aria-hidden="true">×</span>
									</div>
								{/each}
							</div>
				{:else}
					<span class="dropdown-text-content">Select up to 3 states</span>
				{/if}
			{:else}
				<span class="dropdown-text-content">{getDisplayText()}</span>
			{/if}
		</span>
	</button>

	{#if isDropdownOpen}
		<div class="dropdown-menu" transition:fade={{ duration: 200 }}>
			{#each options as option}
				<button
					class="dropdown-item {isSelected(option.value) ? 'selected' : ''}"
					onclick={() => handleSelect(option.value)}
					disabled={isDisabled(option.value)}
				>
					{option.label}
				</button>
			{/each}
		</div>
	{/if}
</div>

<style lang="scss">
	.dropdown-container {
		position: relative;
		width: 100%;

		.dropdown-button {
			width: 100%;
			padding: 0.75rem 1rem;
			border: 1px solid #d0d0d0;
			border-radius: 0.5rem;
			background: #fff;
			color: #666;
			font-size: 0.9rem;
			font-weight: 500;
			cursor: pointer;
			transition: all 0.2s ease;
			font-family: sans-serif;
			display: flex;
			align-items: center;
			justify-content: space-between;
			text-align: left;
			box-sizing: border-box;

			&:hover {
				background-color: #f8f8f8;
				border-color: #999;
			}

			.dropdown-arrow {
				color: #999;
				font-size: 0.75rem;
				transition: transform 0.2s ease;
				flex-shrink: 0;
				transform: rotate(270deg);

				&.is-open {
					transform: rotate(360deg);
				}
			}

			.dropdown-text {
				flex: 1;
				margin-right: 0.5rem;
				display: flex;
				align-items: center;
				gap: 0.25rem;
				overflow: hidden;

				.dropdown-text-content {
					white-space: nowrap;
					overflow: hidden;
					text-overflow: ellipsis;
					flex: 1;
					min-width: 0;
				}
			}

			// State pills styling
			.state-pills {
				display: flex;
				flex-wrap: wrap;
				gap: 0.25rem;
				align-items: center;
				flex: 1;
				overflow: hidden;

				.state-pill {
					display: flex;
					align-items: center;
					background-color: #e8e8e8;
					border-radius: 0.25rem;
					padding: 0.25rem 0.5rem;
					border: 1px solid #d0d0d0;
					transition: all 0.2s ease;
					font-size: 0.75rem;
					flex-shrink: 0;
					cursor: pointer;

					&:hover {
						background-color: #d8d8d8;
						border-color: #b0b0b0;

						.remove-icon {
							color: #333;
						}
					}

					.state-name {
						font-weight: 500;
						color: #333;
						white-space: nowrap;
					}

					.remove-icon {
						color: #666;
						font-weight: bold;
						font-size: 1rem;
						margin-left: 0.25rem;
						transition: color 0.2s ease;
						flex-shrink: 0;
					}
				}
			}
		}

		.dropdown-menu {
			position: absolute;
			top: 100%;
			left: 0;
			right: 0;
			background-color: #fff;
			border-radius: 0.5rem;
			box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
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
				font-size: 0.9rem;
				font-weight: 500;
				cursor: pointer;
				transition: all 0.2s ease;
				font-family: sans-serif;
				text-align: left;
				display: flex;
				align-items: center;
				white-space: normal;
				line-height: 1.4;

				&:hover:not(:disabled) {
					background-color: $color-beacon-yellow;
					color: #333;
				}

				&:first-child {
					border-top-left-radius: 0.5rem;
					border-top-right-radius: 0.5rem;
				}

				&:last-child {
					border-bottom-left-radius: 0.5rem;
					border-bottom-right-radius: 0.5rem;
				}

				&.selected {
					background-color: #eee;
					color: #888;
				}

				&:disabled {
					opacity: 0.5;
					cursor: not-allowed;
					color: #ccc;
				}
			}
		}
	}
</style>

