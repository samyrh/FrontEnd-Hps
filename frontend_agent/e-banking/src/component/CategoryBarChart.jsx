// src/components/CategoryBarChart.jsx

import React from "react";
import { Box, useColorMode, useColorModeValue } from "@chakra-ui/react";
import { Bar } from "react-chartjs-2";
import {
    Chart as ChartJS,
    BarElement,
    CategoryScale,
    LinearScale,
    Tooltip,
    Legend,
    Title,
} from "chart.js";

ChartJS.register(BarElement, CategoryScale, LinearScale, Tooltip, Legend, Title);

export default function CategoryBarChart({ data }) {
    const { colorMode } = useColorMode();
    const containerBg = useColorModeValue("white", "#141f52");
    const fontColor = colorMode === "dark" ? "#ffffff" : "#333333";

    const labels = data.map((item) => item.category);
    const counts = data.map((item) => item.count);

    const chartData = {
        labels,
        datasets: [
            {
                label: "Number of Transactions",
                data: counts,
                backgroundColor: "#dfa7b9",
                borderRadius: 6,
            },
        ],
    };

    const options = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                display: false,
                labels: {
                    color: fontColor,
                },
            },
            title: {
                display: true,
                text: "Number of Transactions by Category",
                font: { size: 18 },
                color: fontColor,
            },
            tooltip: {
                bodyColor: fontColor,
                titleColor: fontColor,
            },
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: { display: true, color: "rgba(255,255,255,0.1)" },
                ticks: {
                    color: fontColor,
                },
            },
            x: {
                grid: { display: false },
                ticks: {
                    color: fontColor,
                },
            },
        },
    };

    return (
        <Box
            bg={containerBg}
            p="6"
            borderRadius="lg"
            boxShadow="lg"
            width="100%"
            height="500px"
        >
            <Bar data={chartData} options={options} />
        </Box>
    );
}
