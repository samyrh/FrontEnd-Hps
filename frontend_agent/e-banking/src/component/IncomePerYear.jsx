import React from "react";
import { Box, useColorMode, useColorModeValue } from "@chakra-ui/react";
import { Line } from "react-chartjs-2";
import {
    Chart as ChartJS,
    LineElement,
    PointElement,
    CategoryScale,
    LinearScale,
    Tooltip,
    Legend,
    Title,
} from "chart.js";

ChartJS.register(LineElement, PointElement, CategoryScale, LinearScale, Tooltip, Legend, Title);

export default function IncomePerYear({ labels, amounts }) {
    const { colorMode } = useColorMode();
    const containerBg = useColorModeValue("white", "#141f52");
    const fontColor = colorMode === "dark" ? "#ffffff" : "#333333";

    const chartData = {
        labels,
        datasets: [
            {
                label: "Total Income per Year",
                data: amounts,
                borderColor: "#c38eb4",
                backgroundColor: "rgba(195, 142, 180, 0.3)",
                pointBackgroundColor: "#c38eb4",
                tension: 0.2,
                fill: true,
            },
        ],
    };

    const options = {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                labels: { color: fontColor },
            },
            title: {
                display: true,
                text: "Income per Year",
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
                ticks: { color: fontColor },
                grid: { color: "rgba(255,255,255,0.1)" },
            },
            x: {
                ticks: { color: fontColor },
                grid: { display: false },
            },
        },
    };

    return (
        <Box
            bg={containerBg}
            p="6"
            borderRadius="lg"
            boxShadow="lg"
            height="400px"
            width="100%"
        >
            <Line data={chartData} options={options} />
        </Box>
    );
}
