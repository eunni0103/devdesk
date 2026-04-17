/* =========================================
   DevDesk 관리자 대시보드 차트 그리기
========================================= */

(function () {

    // 1. 가입자 트렌드 차트 (선 차트)
    const ctxLine = document.getElementById('memberTrendChart').getContext('2d');
    new Chart(ctxLine, {
        type: 'line',
        data: {
            labels: chartLabels_trend,
            datasets: [{
                label: '신규 가입자',
                data: chartData_trend,
                borderColor: '#7c3aed',
                backgroundColor: 'rgba(124, 58, 237, 0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {display: false}
            },
            scales: {
                y: {
                    beginAtZero: true,
                    grid: {color: '#e2e8f0'},
                    ticks: {color: '#64748b'}
                },
                x: {
                    grid: {display: false},
                    ticks: {color: '#64748b'}
                }
            }
        }
    });

    // 2. 직무 카테고리 분포 차트 (도넛 차트)
    const jobColors = chartLabels_job.map(label => {
        if (label === '프론트엔드') return '#5b21b6';
        if (label === '백엔드') return '#7c3aed';
        if (label === '데이터/AI') return '#a78bfa';
        if (label === '기획/디자인') return '#ddd6fe';
        if (label === '미입력(소셜)') return '#94a3b8';
        return '#cbd5e1';
    });

    const ctxDoughnut = document.getElementById('jobDistributionChart').getContext('2d');
    new Chart(ctxDoughnut, {
        type: 'doughnut',
        data: {
            labels: chartLabels_job,
            datasets: [{
                data: chartData_job,
                backgroundColor: jobColors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right',
                    labels: {color: '#475569', font: {size: 14}}
                }
            }
        }
    });

})();