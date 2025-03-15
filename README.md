# Supermarket ProductLine Insight

## Contributor

Zoe Ren

## Motivation

**Target Audience**: Retail Business Analysts and Store Managers

Understanding sales performance across different product lines is crucial for business strategies and profitability. This dashboard provides a straightforward view of supermarket sales, including key metrics such as net sales, gross profit, customer purchase behavior, and sales trends over time.

To address the challenge of managing diverse product categories and customer segments, the dashboard enables users to filter data by city and month, offering deeper insights into regional and seasonal variations. It also presents gender-based purchasing trends(interactive chart) and customer ratings, helping businesses tailor marketing strategies and improve customer experience.

By integrating interactive charts, filters, and key performance indicators (KPIs), this tool empowers stake-holders to visually compare and analyze data ensures that businesses can make data-driven decisions efficiently, leading to better resource allocation and increased revenue.

## App description

## Installation instruction

### Step 1: Set Up the Environment

Ensure that all necessary dependencies are installed by setting up the environment:

```{bash}
conda env create -f environment.yaml
conda activate PL-insight
```

### Step 2: Run the Dashboard

Run the Shiny Dashboard:

```{bash}
Rscript app.R
```

**Click the link** beginning with http://127.0.0.1

This will launch the interactive web dashboard **Supermarket ProductLine Insight**.
