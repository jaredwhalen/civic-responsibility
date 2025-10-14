<script>
	import { scale } from 'svelte/transition';
	import duties from '$lib/data/csvs/mean_duties_weighted.csv';

	let { responses, results, onResults, onLoading, onError } = $props();

	// Sort duties by the number in the name (duties_1, duties_2, etc.)
	const sortedDuties = $derived(
		[...duties].sort((a, b) => {
			const aNum = Number(a.name.replace('duties_', ''));
			const bNum = Number(b.name.replace('duties_', ''));
			return aNum - bNum;
		})
	);

	// Calculate progress
	const progressCount = $derived(
		Object.values(responses).filter((response) => response !== null).length
	);
	const totalCount = $derived(sortedDuties.length);

	// Check if user has selected all 30 behaviors
	const canSubmit = $derived(progressCount >= 30);

	async function submitQuiz() {
		window.scrollTo({ top: 0, behavior: 'instant' });

		try {
			onLoading(true);
			onError(null);
			// Don't call onResults(null) here - only call it on success

			// Structure data for API request
			const dutiesData = {};
			sortedDuties.forEach((duty, index) => {
				const dutyKey = `duties_${index + 1}`;
				dutiesData[dutyKey] = responses[duty.duty_label] ? 1 : 0;
			});

			const requestData = { duties: dutiesData };

			const response = await fetch('https://civic-responsibility.onrender.com/predict', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify(requestData)
			});

			console.log(response);

			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await response.json();

			// Calculate and pass the user's yes count along with results
			const userYesCount = Object.values(responses).filter((response) => response === true).length;
			const totalAnswered = Object.values(responses).filter((response) => response !== null).length;

			onResults({ ...data, userYesCount, totalAnswered: totalAnswered });

			// Scroll to results container to show results with 20px offset
		} catch (err) {
			onError(err.message);
			console.error('Quiz submission error:', err);
		} finally {
			onLoading(false);
		}
	}
</script>

<div class="quiz-footer" class:submitted={results}>
	{#if !results}
		<div class="progress-info">
			<span class="progress-text">{progressCount}/{totalCount} behaviors answered</span>
		</div>
	{/if}
	{#if canSubmit}
		<button class="submit-button" onclick={submitQuiz} transition:scale>
			{results ? 'Resubmit Quiz' : 'Submit Quiz'}
		</button>
	{/if}
</div>

<style lang="scss">
	@import '../../styles/mixins.scss';

	.quiz-footer {
		position: sticky;
		bottom: 0px;
		background: rgba(255, 255, 255, 0.5);
		backdrop-filter: blur(20px);
		-webkit-backdrop-filter: blur(20px);
		border: 1px solid rgba(255, 255, 255, 0.3);
		padding: 1.5rem 2rem;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow:
			0 -4px 15px rgba(0, 0, 0, 0.1),
			0 0 0 1px rgba(255, 255, 255, 0.1);
		z-index: 100;

		&.submitted {
			justify-content: center;
		}

		@include mq('mobile', 'max') {
			padding: 1rem;
			flex-direction: column;
			gap: 1rem;
			text-align: center;
		}

		.progress-info {
			@include mq('mobile', 'max') {
				order: 2;
			}

			.progress-text {
				font-size: 1rem;
				font-weight: 500;
				color: #666;
			}
		}

		.submit-button {
			background: rgba(59, 130, 246, 0.8);
			backdrop-filter: blur(10px);
			-webkit-backdrop-filter: blur(10px);
			border: 1px solid rgba(59, 130, 246, 0.3);
			color: white;
			font-size: 1.2rem;
			font-weight: 600;
			padding: 1rem 3rem;
			border-radius: 12px;
			cursor: pointer;
			transition: all 0.3s ease;
			box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);

			@include mq('mobile', 'max') {
				order: 1;
				padding: 0.5rem;
			}

			&:hover:not(:disabled) {
				transform: translateY(-2px);
				box-shadow: 0 6px 20px rgba(59, 130, 246, 0.4);
				background: rgba(59, 130, 246, 0.9);
				border-color: rgba(59, 130, 246, 0.4);
			}

			&:active:not(:disabled) {
				transform: translateY(0);
			}

			&:disabled {
				background: rgba(156, 163, 175, 0.5);
				backdrop-filter: blur(10px);
				-webkit-backdrop-filter: blur(10px);
				border: 1px solid rgba(156, 163, 175, 0.2);
				cursor: not-allowed;
				opacity: 0.6;
				box-shadow: 0 2px 8px rgba(156, 163, 175, 0.2);
			}
		}
	}
</style>
