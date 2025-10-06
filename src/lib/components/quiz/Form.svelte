<script>
	import duties from '$lib/data/csvs/mean_duties_weighted.csv';

	let { responses = $bindable(), results } = $props();

	// Debugging variable for auto-answering
	let debugAutoAnswer = $state(false);

	let profiles = [
		[1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1],
		[1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0],
		[1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0],
		[1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1],
		[1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0],
		[1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 0, 1]
	];

	let debugAnswers = $state(profiles[7]);

	// Sort duties by the number in the name (duties_1, duties_2, etc.)
	const sortedDuties = $derived(
		[...duties].sort((a, b) => {
			const aNum = Number(a.name.replace('duties_', ''));
			const bNum = Number(b.name.replace('duties_', ''));
			return aNum - bNum;
		})
	);

	// Initialize responses with all duties set to null (only if responses is empty)
	$effect(() => {
		if (sortedDuties && sortedDuties.length > 0 && Object.keys(responses).length === 0) {
			const initialResponses = {};
			sortedDuties.forEach((duty, index) => {
				if (debugAutoAnswer) {
					// Auto-answer based on debugAnswers array
					initialResponses[duty.duty_label] = debugAnswers[index] === 1;
				} else {
					initialResponses[duty.duty_label] = null;
				}
			});
			responses = initialResponses;
		}
	});

	function setResponse(dutyLabel, value) {
		responses[dutyLabel] = value;
		responses = { ...responses }; // Trigger reactivity
	}

	// Calculate progress
	const progressCount = $derived(
		Object.values(responses).filter((response) => response !== null).length
	);
	const totalCount = $derived(sortedDuties.length);
</script>

<div class="quiz-questions">
	{#if results}
		<h3 class="quiz-retake-title">Your responses</h3>
	{/if}
	{#each sortedDuties as duty}
		<div class="quiz-item">
			<div class="quiz-item-label">{duty.duty_label}</div>
			<div class="quiz-buttons">
				<button
					class="quiz-button yes-button"
					class:selected={responses[duty.duty_label] === true}
					onclick={() => setResponse(duty.duty_label, true)}
				>
					Yes
				</button>
				<button
					class="quiz-button no-button"
					class:selected={responses[duty.duty_label] === false}
					onclick={() => setResponse(duty.duty_label, false)}
				>
					No
				</button>
			</div>
		</div>
	{/each}
</div>

<style lang="scss">
	.quiz-questions {
		margin-top: 2rem;
	}

	.quiz-retake-title {
		text-align: center;
		color: var(--color-theme-blue);
		margin-bottom: 1.5rem;
		font-size: 1.5rem;
		font-weight: 600;
        border-top: 2px solid var(--color-theme-blue);
        padding-top: 1.5rem;
        margin-top: 5rem;
	}

	.quiz-item {
		display: flex;
		align-items: center;
		justify-content: space-between;
		padding: 1rem;
		margin-bottom: 0.75rem;
		background-color: #f8f9fa;
		border-radius: 12px;
		border: 2px solid transparent;
		transition: all 0.2s ease;
        

		.quiz-item-label {
			flex: 1;
			font-size: 1.1rem;
			font-weight: 500;
			color: #333;
			margin-right: 1rem;
		}

		.quiz-buttons {
			display: flex;
			gap: 0.5rem;
		}

		.quiz-button {
			padding: 0.5rem 1.5rem;
			border: 2px solid #ddd;
			background-color: white;
			color: #666;
			border-radius: 8px;
			cursor: pointer;
			font-weight: 500;
			transition: all 0.2s ease;
			min-width: 80px;

			&:hover {
				border-color: var(--color-theme-blue);
				color: var(--color-theme-blue);
			}

			&.selected {
				&.yes-button {
					background-color: var(--color-theme-green);
					border-color: var(--color-theme-green);
					color: white;
				}

				&.no-button {
					background-color: var(--color-theme-red);
					border-color: var(--color-theme-red);
					color: white;
				}
			}
		}
	}

	// Responsive design
	@media (max-width: 768px) {
		.quiz-item {
			flex-direction: column;
			align-items: stretch;
			gap: 1rem;

			.quiz-item-label {
				margin-right: 0;
				text-align: center;
			}

			.quiz-buttons {
				justify-content: center;
			}
		}
	}
</style>
