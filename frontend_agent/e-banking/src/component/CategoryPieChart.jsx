// src/components/CategoryPieChart.jsx

import React from "react";
import { Box, useColorMode, useColorModeValue } from "@chakra-ui/react";
import { Pie } from "react-chartjs-2";
import {
    Chart as ChartJS,
    ArcElement,
    Tooltip,
    Legend,
    Title,
} from "chart.js";

ChartJS.register(ArcElement, Tooltip, Legend, Title);

export default function CategoryPieChart({ data }) {
    const { colorMode } = useColorMode();
    const containerBg = useColorModeValue("white", "#141f52");
    const fontColor = colorMode === "dark" ? "#ffffff" : "#333333";

    const labels = data.map((item) => item.category);
    const counts = data.map((item) => item.count);

    const colors = [
        "#d7f9e9", // mint
        "#fdf7c3", // vanilla
        "#ffe4c4", // peach
        "#ffd6d6", // blush pink
        "#f9cfcf", // light coral
        "#ffe9cc", // pale apricot
        "#faf3dd", // cream
        "#dbe8d4", // soft sage
        "#fce1e4", // soft pink
        "#f9e7d9", // warm cream
        "#e7f4f3", // aqua pastel
        "#fef4d3", // light sand
        "#f9dfd9", // rose
        "#fff1dc", // soft vanilla
        "#fdd9d9", // powder blush
        "#fff4e0", // pale almond
        "#fce8e6", // soft rose
        "#fef0db", // light apricot
        "#e9f7ef", // mint cream
        "#fef9e7", // pastel lemon
    ];

    const chartData = {
        labels,
        datasets: [
            {
                data: counts,
                backgroundColor: colors,
                borderWidth: 1,
            },
        ],
    };

    const options = {
        responsive: true,
        plugins: {
            legend: {
                position: "right",
                labels: {
                    color: fontColor,
                    boxWidth: 20,
                },
            },
            title: {
                display: true,
                text: "Category Distribution",
                font: { size: 18 },
                color: fontColor,
            },
            tooltip: {
                bodyColor: fontColor,
                titleColor: fontColor,
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
            <Pie data={chartData} options={options} />
        </Box>
    );
}
