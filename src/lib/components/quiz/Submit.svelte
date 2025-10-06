<script>
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

			if (!response.ok) {
				throw new Error(`HTTP error! status: ${response.status}`);
			}

			const data = await response.json();
      
            
			// Calculate and pass the user's yes count along with results
			const userYesCount = Object.values(responses).filter((response) => response === true).length;
            const totalAnswered = Object.values(responses).filter((response) => response !== null).length;

			onResults({ ...data, userYesCount, totalAnswered: totalAnswered });

			// Scroll to results container to show results with 20px offset
			setTimeout(() => {
				const resultsContainer = document.querySelector('.results-container');
				const quizContainer = document.querySelector('.quiz-container');
				
				if (resultsContainer && quizContainer) {
					// Check if we're in modal mode (has overflow-y: auto) or standalone mode
					const isModal = quizContainer.classList.contains('modal');
					
					if (isModal) {
						// Modal mode: scroll within the container
						const targetY = resultsContainer.offsetTop - 20;
						quizContainer.scrollTo({ top: targetY, behavior: 'smooth' });
					} else {
						// Standalone mode: scroll the window to the results
						const rect = resultsContainer.getBoundingClientRect();
						const targetY = window.scrollY + rect.top - 20;
						window.scrollTo({ top: targetY, behavior: 'smooth' });
					}
				}
			}, 100);
		} catch (err) {
			onError(err.message);
			console.error('Quiz submission error:', err);
		} finally {
			onLoading(false);
		}
	}
</script>

<div class="quiz-footer">
	<div class="progress-info">
		<span class="progress-text">{progressCount}/{totalCount} behaviors answered</span>
	</div>
	<button class="submit-button" onclick={submitQuiz} disabled={!canSubmit}>
		{results ? 'Resubmit Quiz' : 'Submit Quiz'}
	</button>
</div>

<style lang="scss">
	.quiz-footer {
		position: sticky;
		bottom: 0;
		background-color: var(--bg-color);
		padding: 1.5rem 2rem;
		border-top: 1px solid #e9ecef;
		display: flex;
		justify-content: space-between;
		align-items: center;
		box-shadow: 0 -4px 15px rgba(0, 0, 0, 0.1);
		z-index: 100;

		.progress-info {
			.progress-text {
				font-size: 1rem;
				font-weight: 500;
				color: #666;
			}
		}

		.submit-button {
			border: none;
			color: white;
			font-size: 1.2rem;
			font-weight: 600;
			background-color: var(--color-theme-blue-light);
			padding: 1rem 3rem;
			border-radius: 12px;
			cursor: pointer;
			transition: all 0.3s ease;

			padding: 0.5rem 1rem;
			border-radius: 8px;
			border: none;
			cursor: pointer;
			display: inline-block;
			font-size: inherit;
			font-weight: 600;
			transition: all 0.3s ease;
			will-change: transform, opacity;

			&:hover:not(:disabled) {
				transform: translateY(-2px);
				box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
			}

			&:active:not(:disabled) {
				transform: translateY(0);
			}

			&:disabled {
				background-color: #ccc;
				cursor: not-allowed;
				opacity: 0.6;
			}
		}
	}

	// Responsive design
	@media (max-width: 768px) {
		.quiz-footer {
			padding: 1rem;
			flex-direction: column;
			gap: 1rem;
			text-align: center;

			.progress-info {
				order: 2;
			}

			.submit-button {
				order: 1;
			}
		}
	}
</style>
